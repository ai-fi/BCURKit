//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import Foundation
import CommonCrypto

extension Character {
    var isURType: Bool {
        if "a" <= self && self <= "z" { return true }
        if "0" <= self && self <= "9" { return true }
        if self == "-" { return true }
        return false
    }
}

extension String {
    var isURType: Bool { allSatisfy { $0.isURType } }
}
public class Digest {
    public static func sha256(_ data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    public static func sha256(_ hex : String) -> Data {
        let data = Data(hex: hex)
        return self.sha256(data)
    }
}
