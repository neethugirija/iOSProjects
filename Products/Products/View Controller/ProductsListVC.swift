//
//  ViewController.swift
//  Products
//
//  Created by Neethu Girija on 3/21/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import UIKit
import CoreData

class ProductsListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var productList:[Products]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invokeAPIServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
        }
    }
    
    // Initiating API Service & Coredata fetch
    func invokeAPIServices() {
        let apiService = APIService()
        apiService.getInventoryWith { [unowned self] (result) in
            switch result {
            case .Error(let errorMessage):
                self.tableView.isHidden = true
                self.messageView.isHidden = false
                print(errorMessage)
            case .Success(let data):
                self.setUpView(with: data)
            }
        }
    }
    
    //updating coredata & tableview
    private func setUpView(with data: [[String : AnyObject]]){
        CoreDataManager.sharedManager.clearData()
        CoreDataManager.sharedManager.saveInCoreDataWith(data)
        CoreDataManager.sharedManager.fetchedResultsController.delegate = self
        updateView()
    }
    
    fileprivate func updateView() {
        var hasProducts = false
        do {
            try CoreDataManager.sharedManager.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        
        if let products = CoreDataManager.sharedManager.fetchedResultsController.fetchedObjects {
            hasProducts = products.count > 0
        }
        tableView.isHidden = !hasProducts
        messageView.isHidden = hasProducts
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        tableView.reloadData()
    }
    
   
}


//MARK: -Table View DataSource

extension ProductsListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let products = CoreDataManager.sharedManager.fetchedResultsController.fetchedObjects else { return 0 }
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier)
        let product = CoreDataManager.sharedManager.fetchedResultsController.object(at: indexPath)
        cell?.textLabel?.lineBreakMode = .byWordWrapping
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.text = product.productName
        return cell!
    }
}

func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}


//MARK: -Table View Delegate
extension ProductsListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    //MARK: -Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueIdToDetailsVC {
            let productDetailsVC = segue.destination as? ProductDetailsVC
            if let selectedIndex = tableView.indexPathForSelectedRow {
                let product = CoreDataManager.sharedManager.fetchedResultsController.object(at: selectedIndex)
                productDetailsVC?.product = product
            }
        }
    }
    
    //Delete
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let product = CoreDataManager.sharedManager.fetchedResultsController.object(at: indexPath)
            CoreDataManager.sharedManager.delete(product)
        }
    }
}

//MARK: -Fetched Results Controller Delegate

extension ProductsListVC: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        default:
            print("Do nothing")
        }
    }
}
