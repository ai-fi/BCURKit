//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import Foundation

extension Data {
    
    public init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }
    
    public func toHexString() -> String {
        self.bytes.toHexString()
    }
}

