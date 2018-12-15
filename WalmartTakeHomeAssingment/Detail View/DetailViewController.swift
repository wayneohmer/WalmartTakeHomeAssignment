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
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var shortDescriptionLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()
        
        if (self.splitViewController?.isCollapsed ?? false) {
            let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
            rightSwipe.direction = .right
            let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
            leftSwipe.direction = .left
            self.view.addGestureRecognizer(rightSwipe)
            self.view.addGestureRecognizer(leftSwipe)
            self.navigationItem.rightBarButtonItems = nil
        }
        
        self.updateUI()
        
    }
    
    func updateUI() {
        if index < self.products.count {
            self.forwardButton.isEnabled = index != 0
            self.backButton.isEnabled = index < self.products.count - 1
            let product = self.products[index]
            self.titleLabel.text = product.product.productName
            self.priceLabel.text = product.product.price
            if product.product.inStock {
                self.priceLabel.text = "\(self.priceLabel.text ?? "") In Stock"
            } else {
                self.priceLabel.text = "\(self.priceLabel.text ?? "") Backorder"
            }
            if product.product.reviewRating > 0 && product.product.reviewCount > 0 {
                self.ratingLabel.isHidden = false
                self.ratingLabel.text = String(format: "Rating: %1.1f/5 - %d",product.product.reviewRating, product.product.reviewCount)
            } else {
                self.ratingLabel.isHidden = true
            }
            //just in case the image fell out of cache
            product.requestImage() { image, url in
                DispatchQueue.main.async {
                    self.productImageView.image = image
                }
            }
            self.shortDescriptionLabel.attributedText = product.shortDesciprion
            self.descriptionLabel.attributedText = product.longDesciprion
            //ensuers autolayout recalculates.
            self.tableView.reloadData()

        } else {
            self.titleLabel.text = ""
            self.priceLabel.text = ""
            self.ratingLabel.text = ""
            self.productImageView.image = nil
            self.shortDescriptionLabel.attributedText = nil
            self.descriptionLabel.attributedText = nil
        }
            
    }
    
    @IBAction func previousTouched(_ sender: UIBarButtonItem) {
       self.back()
    }
    
    @IBAction func nextTouched(_ sender: UIBarButtonItem) {
        self.forward()
    }
    
    func forward() {
        if self.index < products.count - 1 {
            self.index += 1
        }
        self.updateUI()
    }
    
    func back() {
        if self.index > 0 {
            self.index -= 1
        }
        self.updateUI()
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

