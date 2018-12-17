//
//  ProductsModel.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

//Decodable to parse json.  
struct ProductsSumaryStruct: Decodable {

    var products: [ProductStruct]
    var totalProducts: Int
    var pageNumber: Int
    var pageSize: Int
    var statusCode: Int

}

struct ProductStruct: Decodable {
    
    var productId: String
    var productName: String
    var shortDescription: String? 
    var longDescription: String?
    var price: String
    var productImage: String
    var reviewRating: Double
    var reviewCount: Int
    var inStock: Bool
    
}

