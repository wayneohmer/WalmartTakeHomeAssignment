//
//  WalmartTakeHomeAssingmentTests.swift
//  WalmartTakeHomeAssingmentTests
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import XCTest
@testable import WalmartTakeHomeAssingment

class WalmartTakeHomeAssingmentTests: XCTestCase {

    func testJSONEncoder() {
        guard let filepath:String = Bundle.main.path(forResource: "TestData", ofType: "json") else {
            XCTFail("Could not find JSON file")
            return
        }
        
        do {
            let json = try String(contentsOfFile: filepath)
            print (json)
            do {
                let productFeed = try JSONDecoder().decode(ProductsSumaryStruct.self, from: json.data(using: .utf8)!)
                let products = productFeed.products
                for (idx,product) in products.enumerated() {
                    switch idx {
                    case 0:
                        XCTAssert(product.productId == "003e3e6a-3f84-43ac-8ef3-a5ae2db0f80e", "Wrong productId")
                    case 1:
                        XCTAssert(product.productId == "0150f9b5-8918-4fd1-92b3-fc032cc6c684", "Wrong productId")
                    default:
                        break
                    }
                }

            } catch  {
                XCTFail("Could not decode JSON - \(error.localizedDescription)")
            }
        } catch {
            XCTFail("Could not open JSON file- \(error.localizedDescription)")
        }
    }


}
