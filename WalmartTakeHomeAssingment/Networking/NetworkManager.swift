//
//  NetworkManager.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

enum NetworkingError: Error {
    case message(error:NSError)
    case noData
    case statusError(code:Int)
}

class NetworkManager {
    
    let productUrlString = "https://mobile-tha-server.firebaseapp.com/walmartproducts/"
    let pageSize = "15"
    #if DEBUG
    var errorLogger = ErrorLogManager(errorLogger: ConsoleLogger())
    #else
    var errorLogger = ErrorLogManager(errorLogger: RemoteServiceLogger())
    #endif
    
    func fetchProducts(page: Int, successClosure:@escaping (ProductsSumaryModel) -> Void, failClosure:@escaping (String?) -> Void) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

        guard let productUrl = URL(string: "\(self.productUrlString)\(page)/\(pageSize)") else {
            return
        }
        
        let dataTask = defaultSession.dataTask(with: productUrl) { data, response, error in
            
            do {
                let jsonData = try self.processResponse(data: data, response: response, error: error)
                successClosure(self.getProductsFrom(json: jsonData))
            } catch let error as NetworkingError {
                failClosure(self.handle(error: error))
            } catch {
                failClosure(nil)
            }
        }
        dataTask.resume()
    }
    
    //break this out so it can be tested.
    func processResponse(data:Data?, response:URLResponse?, error:Error?) throws -> Data {
        
        if let error = error as NSError? {
            throw NetworkingError.message(error:error)
        }
        
        let httpResponse = response as? HTTPURLResponse
        
        if httpResponse?.statusCode != 200 {
            throw NetworkingError.statusError(code:httpResponse?.statusCode ?? 0)
        }
        
        guard let data = data else {
            throw NetworkingError.noData
        }
        return data
    }
    
    @discardableResult
    func handle(error:NetworkingError) -> String? {
        
        switch error {
        case .message(let error):
            if let description = error.userInfo["description"] as? String {
                self.errorLogger.log(errorMessage: description)
            } else {
                self.errorLogger.log(errorMessage: error.localizedDescription)
                return error.localizedDescription
            }
        case .statusError(let code):
            self.errorLogger.log(errorMessage: "Status Code: \(code)")
        case .noData:
            self.errorLogger.log(errorMessage: "No Data")
        }
        return nil
    }
    
    func getProductsFrom(json:Data) -> ProductsSumaryModel {
        do {
            let productFeed = try JSONDecoder().decode(ProductsSumaryStruct.self, from: json)
            let products = ProductsSumaryModel(productsSumaryStruct: productFeed)
            return products
        } catch let error {
            print("Could not decode JSON - \(error)")
        }
        return ProductsSumaryModel()
    }
}

