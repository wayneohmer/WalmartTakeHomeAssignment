//
//  MasterViewController.swift
//  WalmartTakeHomeAssignment
//
//  Created by Wayne Ohmer on 12/8/18.
//  Copyright © 2018 Wayne Ohmer. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    var detailViewController: DetailViewController?
    var products = [ProductModel]()
    var totalProducts = 0
    var lastPageFetched = 1
    var lastPageRequested = 1
    let fetchManager = FetchManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.tableFooterView = UIView()

        self.tableView.prefetchDataSource = self
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(self.fetchData), for: .valueChanged)
        
        self.fetchData()

        if let svc = splitViewController {
            let controllers = svc.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    @objc
    func fetchData() {
        fetchManager.fetchProducts(page:self.lastPageRequested, successClosure:self.handle, failClosure:self.networkFailure )
    }

    func handle(productSummary:ProductsSummaryModel) {
        DispatchQueue.main.async {
            self.lastPageFetched = productSummary.productsSumaryStruct?.pageNumber ?? 0
            self.totalProducts = productSummary.productsSumaryStruct?.totalProducts ?? self.totalProducts
            self.products.append(contentsOf: productSummary.products)
            self.tableView.reloadData()
            //This is for the situation when the detail vc shows at launch. iPad portrait or large phone landscape.
            //populate view as soon as data is fetched.
            if let detailVc = self.detailViewController {
                if detailVc.products.count == 0 {
                    detailVc.masterVc = self
                    detailVc.index = 0
                    detailVc.products = self.products
                    if detailVc.isViewLoaded {
                        detailVc.updateUI()
                    }
                }
            }
            //Just in case this was triggered by pull down refresh.
            self.refreshControl?.endRefreshing()
        }
    }
    
    //Very rudimenatry failure messages. Will show custom message if sent.
    func networkFailure(message:String?) {
        
        let alertMessage = message ?? "Network failure."
        let alert = UIAlertController(title: "Cannot Get Products", message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        self.refreshControl?.endRefreshing()

    }
    

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let row = tableView.indexPathForSelectedRow?.row {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.index = row
                controller.masterVc = self
                controller.products = self.products
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
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell else {
            return UITableViewCell()
        }
        let product = self.products[indexPath.row]
        cell.nameLabel.text = product.productName
       
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

    //lazy loading using prefetch. If we are seeing a cell five rows from the bottom, get the next page.  
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        for indexPath in indexPaths {
            if indexPath.row >= self.products.count-5 && self.products.count < self.totalProducts {
                self.lastPageRequested += 1
                self.fetchData()
                break
            }
        }
    }
    
}

