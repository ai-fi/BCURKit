//
//  MiniCBOR.swift
//  BCUR
//
//  Created by Edward Zhan on 8/19/20.
//  Copyright © 2020 Ai-Fi.net, Incorporated. All rights reserved.
//

import XCTest
@testable import BCURKit


class Bech32Tests: XCTestCase {
    
    
    func testEncode() {
        let data = Data(hex: "58bb70736274ff0100520200000001668967b5000d6fd27a798808fe6b4076157fb80d823603e9ea84661521605b6b0000000000ffffffff01d1050f00000000001600142c4fc946e39e6f74115bc6954a46e03f6cf91d8b000000000001011f40420f000000000016001439a66ff5248d45f9b492ae3985a61d34686bc86a220602a671bac2f1f9d0d5181b4e5b1d9ae668ab3b139870cd7f04da107182d8b8667118fb7f7f4554000080000000800000008000000000000000000000")
        let str1 = Bech32.encode(payload: data)
        XCTAssert(str1 == "tzahqumzwnlszqzjqgqqqqqpv6yk0dgqp4hay7ne3qy0u66qwc2hlwqdsgmq8602s3np2gtqtd4sqqqqqqq0llllluqazpg0qqqqqqqqzcqpgtz0e9rw88n0wsg4h354ffrwq0mvlywckqqqqqqqqqgpraqyyrcqqqqqqqqkqq2rnfn075jg630ekjf2uwv95cwng6rtep4zypsz5ecm4sh3l8gd2xqmfed3mxhxdz4nkyucwrxh7px6zpcc9k9cvec337ml0az4gqqqsqqqqqyqqqqqpqqqqqqqqqqqqqqqqqqv0r2uh")
    }
    func testDecode() {
        guard let (prefix, payload) = Bech32.decode("tzahqumzwnlszqzjqgqqqqqpv6yk0dgqp4hay7ne3qy0u66qwc2hlwqdsgmq8602s3np2gtqtd4sqqqqqqq0llllluqazpg0qqqqqqqqzcqpgtz0e9rw88n0wsg4h354ffrwq0mvlywckqqqqqqqqqgpraqyyrcqqqqqqqqkqq2rnfn075jg630ekjf2uwv95cwng6rtep4zypsz5ecm4sh3l8gd2xqmfed3mxhxdz4nkyucwrxh7px6zpcc9k9cvec337ml0az4gqqqsqqqqqyqqqqqpqqqqqqqqqqqqqqqqqqv0r2uh") else {
            return
        }
        XCTAssert(prefix == nil)
        XCTAssert(payload.toHexString() == "58bb70736274ff0100520200000001668967b5000d6fd27a798808fe6b4076157fb80d823603e9ea84661521605b6b0000000000ffffffff01d1050f00000000001600142c4fc946e39e6f74115bc6954a46e03f6cf91d8b000000000001011f40420f000000000016001439a66ff5248d45f9b492ae3985a61d34686bc86a220602a671bac2f1f9d0d5181b4e5b1d9ae668ab3b139870cd7f04da107182d8b8667118fb7f7f4554000080000000800000008000000000000000000000")
    }
    
}
