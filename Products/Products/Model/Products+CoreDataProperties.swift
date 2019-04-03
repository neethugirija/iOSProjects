//
//  Products+CoreDataProperties.swift
//  Products
//
//  Created by Neethu Girija on 3/22/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//
//

import Foundation
import CoreData


extension Products {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Products> {
        return NSFetchRequest<Products>(entityName: Constants.products)
    }

    @NSManaged public var productID: String?
    @NSManaged public var productName: String?
    @NSManaged public var price: String?
    @NSManaged public var mfgDate: String?
    @NSManaged public var descr: String?

}
