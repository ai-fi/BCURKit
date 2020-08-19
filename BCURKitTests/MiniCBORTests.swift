//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import XCTest

@testable import BCURKit

class MiniCBORTests: XCTestCase {
    
    private func dataToUInt16(_ data: Data) -> UInt16 {
        var value = data.withUnsafeBytes { $0.load(as: UInt16.self) }
        value = UInt16(bigEndian: value)
        return value
    }
    
    private func dataToUInt32(_ data: Data) -> UInt32 {
        var value : UInt32 = data.withUnsafeBytes { $0.load(as: UInt32.self) }
        value = UInt32(bigEndian: value)
        return value
    }
    
    private func uint16ToData(_ value: UInt16) -> Data {
        var bigEndian = value.bigEndian
        let bytes = withUnsafeBytes(of: &bigEndian) { Array($0) }
        let data = Data(bytes: bytes, count: 2)
        return data
    }
    
    private func uint32ToData(_ value: UInt32) -> Data {
        var bigEndian = value.bigEndian
        let bytes = withUnsafeBytes(of: &bigEndian) { Array($0) }
        let data = Data(bytes: bytes, count: 4)
        return data
    }
    
    func testInt16ToBytes() {
        let value = UInt16(0xff00)
        let data = uint16ToData(value)
        let newValue = dataToUInt16(data)
        XCTAssert(value == newValue)
        
        let value2 = UInt32(0xff00ff00)
        let data2 = uint32ToData(value2)
        let newValue2 = dataToUInt32(data2)
        XCTAssert(value2 == newValue2)
        
    }
    
    func testFloor() {
        let n: Double = 2.1
        let m = Int(n.rounded(.up))
        
        for i in 0..<m {
            print("\(i) ")
        }
        XCTAssert(m == 3)
    }
    
    func testFragmentString() {
        let str = "abcdefghijklmnopqrstuvwxyz"
        let capacity = 4
        let strLength = str.count
        let frags = Int((Double(strLength) / Double(capacity)).rounded(.up))
        
        for i in 0..<frags {
            var endOffset = (i + 1) * capacity
            if endOffset > strLength {
                endOffset = strLength
            }
            let start = str.index(str.startIndex, offsetBy: i * capacity)
            let end = str.index(str.startIndex, offsetBy: endOffset);
            
            let sub = String(str[start..<end])
            print(sub)
            
        }
    }
}
