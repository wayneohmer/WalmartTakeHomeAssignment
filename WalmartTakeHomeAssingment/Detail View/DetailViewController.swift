//
//  DetailViewController.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var products = [ProductModel]()
    var index = 0
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var shortDescriptionLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        rightSwipe.direction = .right
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        leftSwipe.direction = .left
        
        self.view.addGestureRecognizer(rightSwipe)
        self.view.addGestureRecognizer(leftSwipe)
        
        self.updateUI()
        
    }
    
    func updateUI() {
        if  index < self.products.count {
            let product = self.products[index]
            self.titleLabel.text = product.product.productName
            self.priceLabel.text = product.product.price
            if product.product.inStock {
                self.priceLabel.text = "\(self.priceLabel.text ?? "") In Stock"
            }
            self.productImageView.image = product.image
            self.shortDescriptionLabel.attributedText = product.shortDesciprion
            self.descriptionLabel.attributedText = product.longDesciprion
            //ensuers autolayout recalculates.
            self.tableView.reloadData()
        }
            
    }

    @objc
    func swipe(_ sender: UISwipeGestureRecognizer) {
        
        if self.splitViewController?.isCollapsed ?? false {
            switch sender.direction {
            case .right:
                if self.index > 0 {
                    self.index -= 1
                }
            case .left:
                if self.index < products.count - 1 {
                    self.index += 1
                }
            default:
                break
            }
            self.updateUI()
        }
       
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

