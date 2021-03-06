//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import XCTest

@testable import BCURKit

class UREncoderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEncoding() throws {
        let hex = "70736274ff0100520200000001668967b5000d6fd27a798808fe6b4076157fb80d823603e9ea84661521605b6b0000000000ffffffff01d1050f00000000001600142c4fc946e39e6f74115bc6954a46e03f6cf91d8b000000000001011f40420f000000000016001439a66ff5248d45f9b492ae3985a61d34686bc86a220602a671bac2f1f9d0d5181b4e5b1d9ae668ab3b139870cd7f04da107182d8b8667118fb7f7f4554000080000000800000008000000000000000000000"
        let data = Data(hex: hex)
        XCTAssert(data.toHexString() == hex)
        
        let encoder = UREncoder(data, fragmentCapacity: 200)
        let frags = try encoder.encode()
        XCTAssert(frags.count == 2)
        
        XCTAssert(frags[0].uppercased() == "UR:BYTES/1OF2/LMYDZ7N6J7FKV8DY9HV5DUSVVNTLZ4H53KN4ANN85AT3V6L5VN3QPRX8V2/TZAHQUMZWNLSZQZJQGQQQQQPV6YK0DGQP4HAY7NE3QY0U66QWC2HLWQDSGMQ8602S3NP2GTQTD4SQQQQQQQ0LLLLLUQAZPG0QQQQQQQQZCQPGTZ0E9RW88N0WSG4H354FFRWQ0MVLYWCKQQQQQQQQQGPRAQYYRCQQQQQQQQKQQ2RNFN075JG630EKJF2UWV95CWNG6RT")
        
        XCTAssert(frags[1].uppercased() == "UR:BYTES/2OF2/LMYDZ7N6J7FKV8DY9HV5DUSVVNTLZ4H53KN4ANN85AT3V6L5VN3QPRX8V2/EP4ZYPSZ5ECM4SH3L8GD2XQMFED3MXHXDZ4NKYUCWRXH7PX6ZPCC9K9CVEC337ML0AZ4GQQQSQQQQQYQQQQQPQQQQQQQQQQQQQQQQQQV0R2UH")
    }
}
