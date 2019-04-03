//
//  CoreDataManager.swift
//  Products
//
//  Created by Neethu Girija on 3/27/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    static let sharedManager = CoreDataManager()
    private init() {}
    
    //fetch results controller
    lazy var fetchedResultsController: NSFetchedResultsController<Products> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Products> = Products.fetchRequest()
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.productID, ascending: true)]
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    
    //Creating NSManagedObject for entity product
    private func createProductEntityFrom(dictionary:[String:AnyObject]) -> NSManagedObject? {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let productEntity = NSEntityDescription.insertNewObject(forEntityName: Constants.products, into: context) as? Products {
            //getting values from json response
            productEntity.productID = dictionary[Constants.pId] as? String
            productEntity.productName = dictionary[Constants.productName] as? String
            productEntity.descr = dictionary[Constants.productDesc] as? String
            productEntity.mfgDate = dictionary[Constants.productMfgDate] as? String
            
            if let priceDict = dictionary[Constants.productPrice] as? [String:AnyObject] {
                if let amountDict = priceDict[Constants.productAmount] as? [String:String] {
                    productEntity.price = amountDict[Constants.productRate]
                }
            }
            return productEntity
        }
        return nil
    }
    
    //save product given details
    func saveProductWith(_ name: String, _ id: String, _ desc: String, _ mfgDate: String, _ price: String) -> Void {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        if let productEntity = NSEntityDescription.insertNewObject(forEntityName: Constants.products, into: context) as? Products {
            productEntity.productID = id
            productEntity.productName = name
            productEntity.descr = desc
            productEntity.mfgDate = mfgDate
            productEntity.price = price
            }
        do{
            //saving all products info to coredata
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error{
            print(error)
        }
    }
    
    //update Product details
    func updateProductWith(_ name: String, _ id: String, _ desc: String, _ mfgDate: String, _ price: String, _ product: Products){
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        
        product.productID = id
        product.productName = name
        product.descr = desc
        product.mfgDate = mfgDate
        product.price = price
        
        do{
            //saving all products info to coredata
            try context.save()
        } catch let error{
            print(error)
        }
    }
    
    //delete a Product
    func delete(_ product: Products) {
        let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
        context.delete(product)
        do{
            //saving all products info to coredata
            try context.save()
        } catch let error{
            print(error)
        }
    }
    
    //Saving data from JSON in CoreData
    func saveInCoreDataWith(_ array:[[String:AnyObject]]) {
        //creating entity for each product
        _ = array.map{self.createProductEntityFrom(dictionary: $0)}
        do{
            //saving all products info to coredata
            try CoreDataStack.sharedInstance.persistentContainer.viewContext.save()
        } catch let error{
            print(error)
        }
    }
    
    
    
    //delete all from coredata
    func clearData() {
        do {
            let context = CoreDataStack.sharedInstance.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.products)
            do {
                let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
                _ = objects.map{$0.map{context.delete($0)}}
                CoreDataStack.sharedInstance.saveContext()
            } catch let error {
                print("Error while deleting: \(error)")
            }
        }
    }
}
