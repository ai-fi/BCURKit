//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import Foundation

public final class UREncoder {

    private let data: Data
    private let fragmentCapacity: Int
    private let miniCbor: MiniCBOR
    
    
    /// Start encoding a (possibly) multi-part UR.
    public init(_ data: Data, fragmentCapacity: Int = 200) {
        self.data = data
        self.fragmentCapacity = fragmentCapacity
        self.miniCbor = MiniCBOR()
    }
    
    public func encode() throws -> [String] {
        
        let cborPayload = try self.miniCbor.encodeSimpleCBOR(self.data)
        let bc32Payload = Bech32.encode(payload: cborPayload);//self.bech32.encode(values: cborPayloadHex.utf8)
        let digest = Digest.sha256(cborPayload)
        let bc32Digest = Bech32.encode(payload: digest)
        
        let len = bc32Payload.count
        let frags = Int((Double(len) / Double(self.fragmentCapacity)).rounded(.up))
        
        var fragments: [String] = []
        for i in 0..<frags {
            
            var endOffset = (i + 1) * self.fragmentCapacity
            if endOffset > len {
                endOffset = len
            }
            let start = bc32Payload.index(bc32Payload.startIndex, offsetBy: i * self.fragmentCapacity)
            let end = bc32Payload.index(bc32Payload.startIndex, offsetBy: endOffset);
            
            let fragement = String(bc32Payload[start..<end])
            fragments.append(fragement)
        }
        return composeHeaderToFragments(fragments, digest: bc32Digest)
    }
    private func composeUR(_ payload: String, type: String) -> String {
        return "ur:\(type)/\(payload)"
    }
    
    private func composeSequencing(_ payload: String, index: Int, count: Int) -> String {
        return "\(index + 1)of\(count)/\(payload)"
    }
    
    private func composeDigest(_ payload: String, digest: String) -> String {
        return "\(digest)/\(payload)"
    }
    
    private func composeHeaderToFragments(_ fragments: [String], digest: String, type: String = "bytes") -> [String] {
        if fragments.count == 1 {
            return [composeUR(fragments.first!, type: type)]
        } else {
            var urs = [String]()
            for (idx, fragment) in fragments.enumerated() {
                let ur = composeUR(
                    composeSequencing(
                        composeDigest(fragment, digest: digest),
                        index: idx,
                        count: fragments.count
                    ),
                    type: type
                )
                urs.append(ur)
            }
            return urs
        }
    }

}
