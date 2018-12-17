//
//  DetailViewController.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var masterVc: MasterViewController!
    var index = 0

    var products = [ProductModel]()
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var shortDescriptionLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var backButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.tableFooterView = UIView()
        
        self.updateUI()
        
    }
    
    func updateUI() {
        if index < self.products.count {
            //update selected index for maseter view to keep it in sync.
            self.masterVc.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
            self.masterVc.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
            //Disable buttons that can't be used.
            self.backButton.isEnabled = index != 0
            self.forwardButton.isEnabled = index < self.products.count - 1
            //update labels and images.
            let product = self.products[index]
            self.titleLabel.text = product.productName
            self.priceLabel.text = product.product.price
            if product.product.inStock {
                self.priceLabel.text = "\(self.priceLabel.text ?? "") In Stock"
            } else {
                self.priceLabel.text = "\(self.priceLabel.text ?? "") Backorder"
            }
            //This is ugly. A production app would implement star images.
            if product.product.reviewRating > 0 && product.product.reviewCount > 0 {
                self.ratingLabel.isHidden = false
                self.ratingLabel.text = String(format: "Rating: %1.1f/5 - %d",product.product.reviewRating, product.product.reviewCount)
            } else {
                self.ratingLabel.isHidden = true
            }
            
            //Just in case the image fell out of cache
            product.requestImage() { image, url in
                DispatchQueue.main.async {
                    self.productImageView.image = image
                }
            }
            self.shortDescriptionLabel.attributedText = product.shortDesciprion
            self.descriptionLabel.attributedText = product.longDesciprion
            
            //Ensures autolayout recalculates.
            self.tableView.reloadData()

        } else {
            //make sure everthing is blank if we don't have a product to look at.
            self.titleLabel.text = ""
            self.priceLabel.text = ""
            self.ratingLabel.text = ""
            self.productImageView.image = nil
            self.shortDescriptionLabel.attributedText = nil
            self.descriptionLabel.attributedText = nil
        }
            
    }
    
    @IBAction func backTouched(_ sender: UIBarButtonItem) {
        
        if self.index > 0 {
            self.index -= 1
        }
        self.updateUI()
    }
    
    @IBAction func forwardTouched(_ sender: UIBarButtonItem) {
        if self.index < products.count - 1 {
            self.index += 1
        }
        self.updateUI()
    }
    
    //AutoLayout needs this to be a functions. Setting it in ViewDidLoad doesn't work. 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

