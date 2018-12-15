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
    let fakeUrl = URL(string: "http://test.com")!
    
    var json = ""
    var testData = Data()

    override func setUp() {
        //Generate Fake test data from json file.
        guard let filepath:String = Bundle.main.path(forResource: "TestData", ofType: "json") else {
            XCTFail("Could not find JSON file")
            return
        }
        //Convert JSON to Data to simulate server response.
        do {
            self.json = try String(contentsOfFile: filepath)
            guard let testData = self.json.data(using: .utf8) else {
                XCTFail("Could not encode JSON file")
                return
            }
            self.testData = testData
        } catch {
            XCTFail("Could not open JSON file- \(error)")
        }
        //Inject unit test logging into the networkManger
        self.networkManger.errorLogger = ErrorLogManager(errorLogger: unitTestLogger)
    }
    
    //Test non nil Error.
    func testFetchErrorsError() {
        
        let response = HTTPURLResponse(url: self.fakeUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        let error = NSError(domain: "", code: 0, userInfo: ["description":"Test Error"])
        do {
            let _ = try self.networkManger.processResponse(data: self.testData, response: response, error: error)
            XCTFail("Succeeded with non nil NSError")
        } catch let error as NetworkingError {
            self.networkManger.handle(error: error)
            XCTAssert(self.unitTestLogger.lastMessage == "Test Error")
        } catch {
            XCTFail("Missed NSError error")
        }
    }
    
    func testFetchErrorStatusCode() {
        
        //Test all status codes we care about.
        //This could be altered to test ranges if needed.
        let statusCodes = [201, 400, 403, 500, 503]
        
        for code in statusCodes {
            
            //create fake response with desired statusCode
            let response = HTTPURLResponse(url: self.fakeUrl, statusCode: code, httpVersion: nil, headerFields: nil)
            
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
    
    func testFetchErrorNoData() {
        
        let  response = HTTPURLResponse(url: self.fakeUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            let _ = try networkManger.processResponse(data: nil, response: response, error: nil)
        } catch let error as NetworkingError {
            self.networkManger.handle(error: error)
        } catch {
            XCTFail("Missed Data nil error")
        }
        
    }

    func testFetchDecode() {
        
        let  response = HTTPURLResponse(url: self.fakeUrl, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        do {
            let responseData = try networkManger.processResponse(data: self.testData, response: response, error: nil)
            do {
                let productFeed = try JSONDecoder().decode(ProductsSumaryStruct.self, from: responseData)
                XCTAssert(productFeed.products.count == 2, "Wrong product count")
                XCTAssert(productFeed.totalProducts == 224, "Wrong totalProducts")
                XCTAssert(productFeed.pageNumber == 1, "Wrong pageNumber")
                XCTAssert(productFeed.pageSize == 2, "Wrong pageSize")
                XCTAssert(productFeed.statusCode == 200, "Wrong statusCode")

                let products = productFeed.products
                for (idx,product) in products.enumerated() {
                    switch idx {
                    case 0:
                        XCTAssert(product.productId == "003e3e6a-3f84-43ac-8ef3-a5ae2db0f80e", "Wrong productId")
                        XCTAssert(product.inStock == true, "Wrong inStock")
                        XCTAssert(product.reviewRating == 2, "Wrong reviewRating")
                        XCTAssert(product.reviewCount == 1, "Wrong reviewCount")
                    case 1:
                        XCTAssert(product.productId == "0150f9b5-8918-4fd1-92b3-fc032cc6c684", "Wrong productId")
                        XCTAssert(product.inStock == true, "Wrong inStock")
                        XCTAssert(product.reviewRating == 4.5, "Wrong reviewRating")
                        XCTAssert(product.reviewCount == 2, "Wrong reviewCount")
                    default:
                        break
                    }
                }
                
            } catch  {
                XCTFail("Could not decode JSON - \(error)")
            }
        } catch {
            XCTFail("Good data threw error")
        }
    }
}
