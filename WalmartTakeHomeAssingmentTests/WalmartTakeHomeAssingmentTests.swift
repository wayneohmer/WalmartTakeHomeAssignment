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

    let networkManger = NetworkManager()
    let unitTestLogger = UnitTestLogger()
    var json = ""
    var testData = Data()

    override func setUp() {
        guard let filepath:String = Bundle.main.path(forResource: "TestData", ofType: "json") else {
            XCTFail("Could not find JSON file")
            return
        }
        do {
            self.json = try String(contentsOfFile: filepath)
            guard let testData = self.json.data(using: .utf8) else {
                XCTFail("Could not endoce JSON file")
                return
            }
            self.testData = testData
        } catch {
            XCTFail("Could not open JSON file- \(error)")
        }
        //Inject untit test logging into the networkManger
        self.networkManger.errorLogger = ErrorLogManager(errorLogger: unitTestLogger)
    }
    
    func testNetworkErrorError() {
        
        let response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: "", code: 0, userInfo: ["description":"Test Error"])
        do {
            let _ = try self.networkManger.processResponse(data: self.testData, response: response , error: error)
        } catch let error as NetworkingError {
            self.networkManger.handle(error: error)
            XCTAssert(self.unitTestLogger.lastMessage == "Test Error")
        } catch {
            XCTFail("Missed NSError error")
        }
    }
    func testNetworkErrorStatusCode() {
        
        
        let statusCodes = [201, 400, 403, 500, 503]
        
        for code in statusCodes {
            
            let response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: code, httpVersion: nil, headerFields: nil)
            
            do {
                let _ = try self.networkManger.processResponse(data: self.testData, response: response, error: nil)
                XCTFail("Status code:\(code) did not thow error")
            } catch let error as NetworkingError {
                self.networkManger.handle(error: error)
                XCTAssert(self.unitTestLogger.lastMessage == "Status Code: \(code)", self.unitTestLogger.lastMessage)
            } catch {
                XCTFail("Missed statusCode error")
            }
        }
    }
    
    func testNetworkErrorNoData() {
        
        let  response = HTTPURLResponse(url: URL(string: "http://test.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            let _ = try networkManger.processResponse(data: nil, response: response, error: nil)
        } catch let error as NetworkingError {
            self.networkManger.handle(error: error)
        } catch {
            XCTFail("Missed Data nil error")
        }
        
    }

    func testJSONEncoder() {
        
        do {
            let productFeed = try JSONDecoder().decode(ProductsSumaryStruct.self, from: self.testData)
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
            XCTFail("Could not decode JSON - \(error)")
        }
    }
}
