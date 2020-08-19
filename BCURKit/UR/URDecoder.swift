//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import Foundation

public final class URDecoder {
    
    public enum Error: Swift.Error {
        case invalidScheme
        case invalidType
        case invalidPathLength
        case invalidSequenceComponent
        case invalidFragment
        case invalidDigest
        case invalidCborPayload
        case needMoreFragments
    }

    public var expectedType: String?
    private var expectedFragmentCount: Int!
    private var fragmentMap: [Int: Fragment] = [:]
    private var expectedDigest: String?
    
    struct Fragment {
        var sequece: Int
        var count: Int
        var payload: String
    }

    public init() {
        
    }

    @discardableResult public func receiveFragment(_ string: String) -> (Data?, Swift.Error?) {
        do {
            // Don't continue if this fragement doesn't validate
            let (type, components) = try self.parse(string)
            guard validateType(type: type) else {
                return (nil, Error.invalidFragment)
            }

            // If this is a single-part UR then we're done
            if components.count == 1 {
                let fragment = components[0]
                if !validateFragment(seqNum: 1, seqLen: 1) {
                    return (nil, Error.invalidFragment)
                }
                let frag = Fragment(sequece: 1, count: 1, payload: fragment)
                self.fragmentMap[1] = frag
            } else if components.count == 2 {
                let seq = components[0]
                let fragment = components[1]
                
                let (seqNum, seqLen) = try self.parseSequenceComponent(seq)
                if !validateFragment(seqNum: seqNum,seqLen: seqLen) {
                    return (nil, Error.invalidFragment)
                }
                
                let frag = Fragment(sequece: seqNum, count: seqLen, payload: fragment)
                self.fragmentMap[seqNum] = frag
                
            } else if components.count == 3 {
                let seq = components[0]
                let digest = components[1]
                let fragment = components[2]

                let (seqNum, seqLen) = try self.parseSequenceComponent(seq)
                
                if !validateFragment(seqNum: seqNum, seqLen: seqLen, digest: digest) {
                    return (nil, Error.invalidFragment)
                }
                
                let frag = Fragment(sequece: seqNum, count: seqLen, payload: fragment)
                self.fragmentMap[seqNum] = frag
                
            } else {
                return (nil, Error.invalidFragment)
            }

            if self.fragmentMap.count != self.expectedFragmentCount {
                return (nil, Error.needMoreFragments)
            }
            
            return validateAndCombineFragments()
            
        } catch {
            return (nil, error)
        }
    }
    
    private func validateDigest(_ cborPayload: Data) -> Bool {
        
        guard let expectedDigest = self.expectedDigest else {
            return true
        }
        
        guard let (_, expectedDigestData) = Bech32.decode(expectedDigest) else {
            return false
        }
        
        let digestData = Digest.sha256(cborPayload)
        if expectedDigestData != digestData {
            return false
        }
        return true
    }
    
    private func validateAndCombineFragments() -> (Data?, Error?)  {
    
        var fragArray = [Fragment]()
        
        for i in 1...self.expectedFragmentCount {
            guard let frag = self.fragmentMap[i] else {
                return (nil, Error.needMoreFragments)
            }
            fragArray.append(frag)
        }
        
        var payload = String()
        for frag in fragArray {
            payload = payload + frag.payload
        }
        
        guard let (_, cborPayload) = Bech32.decode(payload) else {
            return (nil, Error.invalidCborPayload)
        }
        
        if !self.validateDigest(cborPayload) {
            return (nil, Error.invalidDigest)
        }
        
        do {
            let realPayload = try MiniCBOR().decodeSimpleCBOR(cborPayload)
            return (realPayload, nil)
        } catch {
            return (nil, Error.invalidCborPayload)
        }
    }

    private func validateType(type: String) -> Bool {
        if expectedType == nil {
            guard type.isURType else { return false }
            expectedType = type
        } else {
            return type == expectedType
        }
        return true
    }
    
    
    private func validateFragment(seqNum: Int, seqLen: Int, digest: String? = nil) -> Bool {
        // If this is the first fragment we've seen
        if expectedFragmentCount == nil {
            // Record the things that all the other fragments we see will have to match to be valid.
            expectedFragmentCount = seqLen
            expectedDigest = digest
        } else {
            // If this fragment's values don't match the first fragment's values
            guard expectedFragmentCount == seqLen,
                  expectedDigest == digest,
                  seqNum <= expectedFragmentCount
            else {
                // Throw away the fragment
                return false
            }
        }
        // This fragment should be processed
        return true
    }
    
    func parse(_ string: String) throws -> (type: String, components: [String]) {
        // Don't consider case
        let lowered = string.lowercased()

        // Validate URI scheme
        guard lowered.hasPrefix("ur:") else { throw Error.invalidScheme }
        let path = lowered.dropFirst(3)

        // Split the remainder into path components
        let components = path.split(separator: "/").map { String($0) }

        // Make sure there are at least two path components
        guard components.count > 1 else {
            throw Error.invalidPathLength
        }

        // Validate the type
        let type = components[0]
        guard type.isURType else { throw Error.invalidType }

        return (type, Array(components[1...]))
    }

    func parseSequenceComponent(_ s: String) throws -> (seqNum: Int, seqLen: Int) {
        let scanner = Scanner(string: s)
        guard let seqNum = scanner.scanInt() else { throw Error.invalidSequenceComponent }
        guard scanner.scanString("of") != nil else { throw Error.invalidSequenceComponent }
        guard let seqLen = scanner.scanInt() else { throw Error.invalidSequenceComponent }
        guard scanner.isAtEnd else { throw Error.invalidSequenceComponent }
        guard seqNum >= 1, seqLen >= 1 else { throw Error.invalidSequenceComponent }
        return (seqNum, seqLen)
    }
    
}
