//
//  DetailViewController.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var product:ProductModel?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var shortDescriptionLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        
        if let product = self.product {
            
            self.titleLabel.text = product.product.productName
            self.priceLabel.text = product.product.price
            if product.product.inStock {
                self.priceLabel.text = "\(self.priceLabel.text ?? "") In Stock"
            }
            self.productImageView.image = product.image
            self.shortDescriptionLabel.attributedText = self.product?.shortDesciprion
            self.descriptionLabel.attributedText = self.product?.longDesciprion

            
        }
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

