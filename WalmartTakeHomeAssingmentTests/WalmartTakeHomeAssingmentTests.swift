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
    
    
    func testNetworkErrorError() {
        let networkManger = NetworkManager()
        let error = NSError(domain: "", code: 0, userInfo: ["description":"Test error"])
        do {
            let _ = try networkManger.processResponse(data: nil, response: nil, error: error)
        } catch let error as NetworkingError {
            networkManger.handle(error: error)
        } catch {
            XCTFail("Missed NSError error")
        }
    }
    func testNetworkErrorStatusCode() {
        
        let networkManger = NetworkManager()

        let response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        
        do {
            let _ = try networkManger.processResponse(data: nil, response: response, error: nil)
        } catch let error as NetworkingError {
            networkManger.handle(error: error)
        } catch {
            XCTFail("Missed statusCode error")
        }
    }
    
    func testNetworkErrorNoData() {
        
        let networkManger = NetworkManager()

        let  response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            let _ = try networkManger.processResponse(data: nil, response: response, error: nil)
        } catch let error as NetworkingError {
            networkManger.handle(error: error)
        } catch {
            XCTFail("Missed Data nil error")
        }
        
    }

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
