//
//  MasterViewController.swift
//  WalmartTakeHomeAssingment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var products = [ProductModel]()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()

        let networkManager = NetworkManager()
       
        networkManager.fetchProducts(closure:self.handle)
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    func handle(productSummary:ProductsSumaryModel) {
        DispatchQueue.main.async {
            self.products = productSummary.products
            self.tableView.reloadData()
        }
    }
    

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.product = products[indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        let product = self.products[indexPath.row]
        cell.nameLabel.text = product.product.productName
        cell.priceLabel.text = product.product.price
        //Store the url for later verification.
        cell.imageUrlString = product.imageUrl?.absoluteString ?? ""
        
        product.requestImage(){ [weak cell] (image, urlString) in
            DispatchQueue.main.async {
                // Make sure image url is still the url that was requested. Reused cells can have the wrong image displayed if we do not verify.
                if cell?.imageUrlString == urlString {
                    cell?.productImageView.image = image
                }
            }
        }
        
        return cell
    }


}

