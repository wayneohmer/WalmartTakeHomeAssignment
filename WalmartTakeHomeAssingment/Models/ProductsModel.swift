//
//  ProductsModel.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class ProductsSumaryModel {
    
    var productsSumaryStruct: ProductsSumaryStruct?
    var products = [ProductModel]()

    convenience init(productsSumaryStruct: ProductsSumaryStruct) {
        self.init()
        self.productsSumaryStruct = productsSumaryStruct
        for productStruct in productsSumaryStruct.products {
            self.products.append(ProductModel(product: productStruct))
        }
    }
}

class ProductModel {
    
    var product: ProductStruct
    
    var imageUrl: URL? {
        return URL(string: "https://mobile-tha-server.firebaseapp.com/\(self.product.productImage)")
    }
    var image:UIImage?
    //Don't save requests if fetch has failed.
    var fetchFailed = false
    
    //when a request comes in while the is being fetched, store them until the fetch is done.
    var requestImageClosures = [((UIImage, String) -> Void)]()
    
    required init(product: ProductStruct) {
        self.product = product
        self.fetchImage()
    }
    
    func requestImage(closure:@escaping (UIImage, String) -> Void) {
        if let image = self.image, let url = self.imageUrl {
            closure(image, url.absoluteString)
        } else {
            //Don't save closure if fetch failed and there should never be more then 2 open requests.
            if !self.fetchFailed && self.requestImageClosures.count < 2 {
                self.requestImageClosures.append(closure)
            }
        }
    }
    
    func fetchImage(){
        guard let url = self.imageUrl else {
            self.fetchFailed = true
            return
        }
        self.fetchFailed = false
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = defaultSession.dataTask(with: url) { data, response, error in
            //No error identification or retries. A production app would be more robust.
            if let imageData = data, let image = UIImage(data: imageData) {
                self.image = image
                for closure in self.requestImageClosures {
                    closure(image, url.absoluteString)
                }
            } else {
                self.fetchFailed = true
                self.requestImageClosures.removeAll()
            }
        }
        dataTask.resume()
    }
    
}
