//
//  NetworkManager.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

enum NetworkingError: Error {
    case message(error:Error)
    case noData
    case statusError(code:Int)
}

class NetworkManager {
    
    let productUrlString = "https://mobile-tha-server.firebaseapp.com/walmartproducts/"
    
    func fetchProducts(page: Int, closure:@escaping (ProductsSumaryModel) -> Void) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

        guard let productUrl = URL(string: "\(self.productUrlString)\(page)/15") else {
            return
        }
        
        let dataTask = defaultSession.dataTask(with: productUrl) { data, response, error in
            
            do {
                let jsonData = try self.processResponse(data: data, response: response, error: error)
                closure(self.getProductsFrom(json: jsonData))
            } catch let error as NetworkingError {
                self.handle(error: error)
            } catch {
                
            }
            
        }
        dataTask.resume()
    }
    
    //break this out so it can be tested.
    func processResponse(data:Data?, response:URLResponse?, error:Error?) throws -> Data {
        
        if let error = error {
            throw NetworkingError.message(error:error)
        }
        
        let httpResponse = response as? HTTPURLResponse
        
        if httpResponse?.statusCode == 500 {
            throw NetworkingError.statusError(code:httpResponse?.statusCode ?? 0)
        }
        
        guard let data = data else {
            throw NetworkingError.noData
        }
        return data
    }
    
    func handle(error:NetworkingError) {
        
        switch error {
        case .message(let error):
            print(error)
        case .statusError(let code):
            print(code)
        case .noData:
            print ("No Data")
        }
        
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

