//
//  FetchManager.swift
//  WalmartTakeHomeAssignment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

enum FetchError: Error {
    case message(error:NSError)
    case statusError(code:Int)
    case noData
    case decodeError(error:NSError)
}

class FetchManager {
    
    let productUrlString = "https://mobile-tha-server.firebaseapp.com/walmartproducts/"
    let pageSize = "15"
    
    //print errors to the console in DEBUG mode. Otherwise, send to remote service.
    #if DEBUG
    var errorLogger = ErrorLogManager(errorLogger: ConsoleLogger())
    #else
    var errorLogger = ErrorLogManager(errorLogger: RemoteServiceLogger())
    #endif
    
    func fetchProducts(page: Int, successClosure:@escaping (ProductsSummaryModel) -> Void, failClosure:@escaping (String?) -> Void) {
        
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

        guard let productUrl = URL(string: "\(self.productUrlString)\(page)/\(pageSize)") else {
            failClosure(nil)
            return
        }
        
        let dataTask = defaultSession.dataTask(with: productUrl) { data, response, error in
            
            do {
                let productSummary = try self.processResponse(data: data, response: response, error: error)
                successClosure(productSummary)
            } catch let error as FetchError {
                failClosure(self.handleError(error: error) )
            } catch {
                failClosure(nil)
            }
        }
        dataTask.resume()
    }
    
    //break this out so it can be tested.
    func processResponse(data:Data?, response:URLResponse?, error:Error?) throws -> ProductsSummaryModel {
        
        if let error = error as NSError? {
            throw FetchError.message(error:error)
        }
        
        let httpResponse = response as? HTTPURLResponse
        
        if httpResponse?.statusCode != 200 {
            throw FetchError.statusError(code:httpResponse?.statusCode ?? 0)
        }
        
        guard let data = data else {
            throw FetchError.noData
        }
        
        do {
            let products = try self.getProductsFrom(data:data)
            return products
        } catch let error {
            throw error
        }
        
    }
    
    @discardableResult
    func handleError(error:FetchError) -> String? {
        
        switch error {
        case .message(let error):
            //check for fake test message. This could be expanded to check for other useful messages.
            if let description = error.userInfo["description"] as? String {
                self.errorLogger.log(errorMessage: description)
            } else {
                self.errorLogger.log(errorMessage: error.localizedDescription)
                return error.localizedDescription
            }
        case .statusError(let code):
            //This could be expanded to handle different codes or code ranges in different ways.
            self.errorLogger.log(errorMessage: "Status Code: \(code)")
        case .noData:
            self.errorLogger.log(errorMessage: "Data was nil")
        case .decodeError(let error):
            //This could be expanded to log more useful messages.  
            self.errorLogger.log(errorMessage: error.localizedDescription)
        }
        return nil
    }
    
    func getProductsFrom(data:Data) throws -> ProductsSummaryModel {
        
        //If it were possible for data to contain JSON with and error message in it, we could
        //check for that here and throw an appropriate error.
        
        do {
            let productFeed = try JSONDecoder().decode(ProductsSumaryStruct.self, from: data)
            let products = ProductsSummaryModel(productsSumaryStruct: productFeed)
            return products
        } catch let error as NSError {
            throw FetchError.decodeError(error: error)
        }
    }
}

