//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import Foundation

public struct Bech32 {
    internal static let generator: [UInt32] = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]
    internal static let base32Alphabets = "qpzry9x8gf2tvdw0s3jn54khce6mua7l"

    public static func encode(prefix: String? = nil, payload: Data) -> String {
        let payloadUint5 = convertTo5bit(data: payload, pad: true)
        let checksumUint5: Data = createChecksum(prefix: prefix, payload: payloadUint5) // Data of [UInt5]
        let combined: Data = payloadUint5 + checksumUint5 // Data of [UInt5]
        var base32 = ""
        for b in combined {
            let index = String.Index(utf16Offset: Int(b), in: base32Alphabets)
            base32 += String(base32Alphabets[index])
        }
        
        if prefix != nil {
            return prefix! + ":" + base32
        }
        return base32
    }

    public static func decode(_ string: String) -> (prefix: String?, data: Data)? {
        // We can't have empty string.
        // Bech32 should be uppercase only / lowercase only.
        guard !string.isEmpty && [string.lowercased(), string.uppercased()].contains(string) else {
            return nil
        }

        let components = string.components(separatedBy: ":")
        let (prefix, base32): (String?, String)
        // We can only handle string contains both scheme and base32
        if components.count == 1 {
            (prefix, base32) = (nil, components[0])
        } else if components.count == 2 {
            (prefix, base32) = (components[0], components[1])
        } else {
            return nil
        }

        var decodedIn5bit: [UInt8] = [UInt8]()
        for c in base32.lowercased() {
            // We can't have characters other than base32 alphabets.
            guard let baseIndex = base32Alphabets.firstIndex(of: c)?.utf16Offset(in: base32Alphabets) else {
                return nil
            }
            decodedIn5bit.append(UInt8(baseIndex))
        }

        // We can't have invalid checksum
        let payload = Data(decodedIn5bit)
        guard verifyChecksum(prefix: prefix, payload: payload) else {
            return nil
        }

        // Drop checksum
        guard let bytes = try? convertFrom5bit(data: payload.dropLast(6)) else {
            return nil
        }
        return (prefix, Data(bytes))
    }

    internal static func verifyChecksum(prefix: String?, payload: Data) -> Bool {
        var expandedHrp: Data = Data(repeating: 0, count: 1)
        if prefix != nil {
            expandedHrp = expand(prefix!)
        }
        return polymod(expandedHrp + payload) == UInt32(0x3fffffff)
    }

    internal static func expand(_ prefix: String) -> Data {
        var ret: Data = Data()
        let buf: [UInt8] = Array(prefix.utf8)
        for b in buf {
            ret.append(UInt8(b & 0x1f))
        }
        ret += Data(repeating: 0, count: 1)
        return ret
    }

    internal static func createChecksum(prefix: String?, payload: Data) -> Data {
        var expandedHrp: Data = Data(repeating: 0, count: 1)
        if prefix != nil {
            expandedHrp = expand(prefix!)
        }
        
        let enc: Data = expandedHrp + payload + Data(repeating: 0, count: 6)
        let chk = UInt32(0x3fffffff)
        let mod: UInt32 = polymod(enc) ^ chk
        var ret: Data = Data()
        for i in 0..<6 {
            ret.append(UInt8(UInt8((mod >> (5 * (5 - i))) & 0x1f)))
        }
        return ret
    }
    
    private static func polymod(_ values: Data) -> UInt32 {
        var chk: UInt32 = 1
        for v in values {
            let top = (chk >> 25)
            chk = (chk & 0x1ffffff) << 5 ^ UInt32(v)
            for i: UInt8 in 0..<5 {
                chk ^= ((top >> i) & 1) == 0 ? 0 : generator[Int(i)]
            }
        }
        return chk
    }
    
    internal static func PolyMod(_ data: Data) -> UInt64 {
        var chk: UInt64 = 1
        for d in data {
            let top_1: UInt64 = UInt64(chk >> 25)
            chk = ((chk & 0x1ffffff) << 5) ^ UInt64(d)
            for i in 0..<6 {
                if ((top_1 >> i) & 1) != 0 {
                    chk ^= UInt64(generator[i])
                }
            }
        }
        return chk
    }

    internal static func convertTo5bit(data: Data, pad: Bool) -> Data {
        var acc = Int()
        var bits = UInt8()
        let maxv: Int = 31 // 31 = 0x1f = 00011111
        var converted: [UInt8] = []
        for d in data {
            acc = (acc << 8) | Int(d)
            bits += 8

            while bits >= 5 {
                bits -= 5
                converted.append(UInt8(acc >> Int(bits) & maxv))
            }
        }

        let lastBits: UInt8 = UInt8(acc << (5 - bits) & maxv)
        if pad && bits > 0 {
            converted.append(lastBits)
        }
        return Data(converted)
    }

    internal static func convertFrom5bit(data: Data) throws -> Data {
        var acc = Int()
        var bits = UInt8()
        let maxv: Int = 255 // 255 = 0xff = 11111111
        var converted: [UInt8] = []
        for d in data {
            guard (d >> 5) == 0 else {
                throw DecodeError.invalidCharacter
            }
            acc = (acc << 5) | Int(d)
            bits += 5

            while bits >= 8 {
                bits -= 8
                converted.append(UInt8(acc >> Int(bits) & maxv))
            }
        }

        let lastBits: UInt8 = UInt8(acc << (8 - bits) & maxv)
        guard bits < 5 && lastBits == 0  else {
            throw DecodeError.invalidBits
        }

        return Data(converted)
    }

    internal enum DecodeError: Error {
        case invalidCharacter
        case invalidBits
    }
}
