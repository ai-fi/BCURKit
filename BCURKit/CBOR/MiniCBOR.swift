//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import Foundation

public class MiniCBOR {
    
    
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
    
    private func composeHeader(_ length: Int) -> Data {
        var headerData = Data()
        if length > 0 && length <= 23 {
            headerData.append(UInt8(0x40 + length))
        } else if length >= 24 && length <= 255 {
            headerData.append(UInt8(0x58))
            headerData.append(UInt8(length))
        } else if length >= 256 && length <= 65535 {
            headerData.append(UInt8(0x59))
            var bigEndian = UInt16(length).bigEndian
            let bytes = withUnsafeBytes(of: &bigEndian) { Array($0) }
            headerData.append(bytes, count: 2)
        } else if length > 65535 || length >= Int(pow(2.0, 32)) {
            headerData.append(UInt8(0x60))
            var bigEndian = length.bigEndian
            let bytes = withUnsafeBytes(of: &bigEndian) { Array($0) }
             headerData.append(bytes, count: 4)
        }
        return headerData
    }
    
    public func encodeSimpleCBOR(_ data: Data) throws -> Data {
        
        if data.count <= 0 || data.count >= Int(pow(2.0, 32)) {
            throw MiniCBORError.invalidData
        }
        
        var encodedData = composeHeader(data.count)
        encodedData.append(data)
        return encodedData
    }
    
    public func decodeSimpleCBOR(_ data: Data) throws -> Data {
        
        if data.count <= 0 {
            throw MiniCBORError.invalidData
        }
        
        let firstByte = data.bytes[0]
        if firstByte < 0x58 {
            let len = firstByte - 0x40
            return data.subdata(in: 1..<Int(len)+1)
        } else if firstByte == 0x58 {
            let len = data.bytes[1]
            return data.subdata(in: 2..<Int(len)+2)
        } else if firstByte == 0x59 {
            let lenData = data.subdata(in: 1..<3)
            let len = dataToUInt16(lenData)
            return data.subdata(in: 3..<Int(len)+3)
        } else if firstByte == 0x60 {
            let lenData = data.subdata(in: 1..<5)
            let len = dataToUInt32(lenData)
            return data.subdata(in: 5..<Int(len)+5)
        } else {
            throw MiniCBORError.invalidData
        }
    }
    
    public func encode(_ hex: String) throws -> String {
        
        let data = Data(hex: hex)
        let encodedData = try encodeSimpleCBOR(data)
        return encodedData.toHexString()
    }
    
    public func decode(_ hex: String) throws -> String {
        
        let data = Data(hex: hex)
        
        let decodedData = try decodeSimpleCBOR(data)
        return decodedData.toHexString()
    }
}


extension MiniCBOR {
    public enum MiniCBORError: LocalizedError {
        case invalidData
        
        public var errorDescription: String? {
            switch self {
            case .invalidData:
                return "Invalid data"
            }
        }
    }
}
