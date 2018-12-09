//
//  NetworkManager.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class NetworkManager {
    
    let productUrl = URL(string:"https://mobile-tha-server.firebaseapp.com/walmartproducts/1/15")!
    
    func fetchProducts(closure:@escaping (ProductsSumaryModel) -> Void) {
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)

        let dataTask = defaultSession.dataTask(with: productUrl) { data, response, error in
            guard let jsonData = data else {
                closure(ProductsSumaryModel())
                return
            }
            closure(self.getProductsFrom(json: jsonData))
        }
        dataTask.resume()
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

