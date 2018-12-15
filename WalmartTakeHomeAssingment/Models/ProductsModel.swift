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
    
    static var imageDirectory = "\(NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0])/WalmartImages"
    
    var product: ProductStruct
    
    private var cachedImageUrl: URL {
        return URL(fileURLWithPath:"\(ProductModel.imageDirectory)/\(self.product.productId)")
    }
    
    var imageUrl: URL? {
        return URL(string: "https://mobile-tha-server.firebaseapp.com/\(self.product.productImage)")
    }
    
    //private because consumer should only use requestImage()
    private var image:UIImage? {
        return UIImage(contentsOfFile: cachedImageUrl.relativePath)
    }
    
    var shortDesciprion:NSAttributedString? {
        return sizefontsFrom(string: self.convertHtmlFrom(string: self.product.shortDescription))
    }
    var longDesciprion:NSAttributedString? {
        return sizefontsFrom(string: self.convertHtmlFrom(string: self.product.longDescription))
    }
    
    //Don't save requests if fetch has failed.
    var fetchFailed = false
    
    //when a request comes in while the is being fetched, store them until the fetch is done.
    var requestImageClosures = [((UIImage, String) -> Void)]()
    
    required init(product: ProductStruct) {
        self.product = product
        self.fetchImage()
    }
    
    func sizefontsFrom(string:NSMutableAttributedString?) -> NSAttributedString? {
       
        guard let string = string else {
            return nil
        }
        string.enumerateAttribute(.font, in: NSRange(0..<string.length)) { value, range, stop in
            if let font = value as? UIFont {
                var fontMetrics = UIFontMetrics(forTextStyle: .body)
                if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                    fontMetrics = UIFontMetrics(forTextStyle: .title2)
                }
                let size = fontMetrics.scaledFont(for:UIFont.systemFont(ofSize: 17)).pointSize
                let newFont = UIFont(name: font.fontName, size: size) ?? font
                string.removeAttribute(.font, range: range)
                string.addAttribute(.font, value: newFont, range: range)
            }
        }
        return string
    }
    
    func convertHtmlFrom(string:String?) -> NSMutableAttributedString? {
        if let shortHtmlData = NSString(string: string ?? "").data(using: String.Encoding.unicode.rawValue) {
            do {
                let attributedString = try NSMutableAttributedString(data: shortHtmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                return attributedString
            } catch {
            }
        }
        return nil
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
        //if we have an image, don't fetch.  
        if let _ = self.image {
            return
        }
        self.fetchFailed = false
        let defaultSession = URLSession(configuration: URLSessionConfiguration.default)
        let dataTask = defaultSession.dataTask(with: url) { data, response, error in
            //No error identification or retries. A production app would be more robust.
            guard let imageData = data, let image = UIImage(data: imageData) else {
                self.fetchFailed = true
                self.requestImageClosures.removeAll()
                return
            }
            do {
                try imageData.write(to: self.cachedImageUrl)
            } catch {
                self.fetchFailed = true
                self.requestImageClosures.removeAll()
            }
            for closure in self.requestImageClosures {
                closure(image, url.absoluteString)
            }
        }
        dataTask.resume()
    }
    
}
