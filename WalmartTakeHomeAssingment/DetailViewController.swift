//
//  DetailViewController.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var product:ProductModel?
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var shortDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let product = self.product {
            
            self.productImageView.image = product.image
            if let shortHtmlData = NSString(string: product.product.shortDescription ?? "").data(using: String.Encoding.unicode.rawValue) {
                do {
                    let attributedString = try NSAttributedString(data: shortHtmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                    shortDescriptionLabel.attributedText = attributedString
                } catch {
                    
                }
            }
            if let longHtmlData = NSString(string: "\n\n\(product.product.longDescription ?? "")").data(using: String.Encoding.unicode.rawValue) {
                do {
                    let attributedString = try NSAttributedString(data: longHtmlData, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                   
                    descriptionTextView.attributedText = attributedString
                } catch {
                    
                }
            }
            
            
        }
        
    }



}

