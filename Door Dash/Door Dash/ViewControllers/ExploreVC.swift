//
//  RestaurantListVC.swift
//  Door Dash
//
//  Created by Neethu Girija on 4/16/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import UIKit
import SDWebImage
import CoreLocation

class ExploreVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
   
    
    var restaurantList = [Restaurant]()
    var location: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        invokeAPIServices()
    }
    
    func invokeAPIServices(){
        let apiServices = APIServices()
        
        guard let selectedLocation = location else {return}
        
        apiServices.getData(for: selectedLocation) { [unowned self] (result) in
            switch result {
            case .Error(let message) :
                print(message)
            case .Success(let list):
                self.restaurantList = list
                if list.count == 0 {
                    let alert = UIAlertController.init(title: "DoorDash", message: "No data available", preferredStyle: .alert)
                    let action = UIAlertAction.init(title: "OK", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
                self.tableView.reloadData()
            }
        }
    }
}

extension ExploreVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RestaurantCell = self.tableView.dequeueReusableCell(withIdentifier: "restaurantCell") as! RestaurantCell
        let restaurant = restaurantList[indexPath.row]
        cell.restaurantNameLabel.text = restaurant.name
        cell.cusineLabel.text = restaurant.description
        if let imageUrl = restaurant.imageUrl {
            cell.restaurantLogo.sd_setImage(with: URL(string:imageUrl), placeholderImage: nil)
        }
        if restaurant.deliveryFee == 0 {
            cell.deliveryFeeLabel.text = "Free delivery"
        } else {
            cell.deliveryFeeLabel.text = "$\(restaurant.deliveryFee!) delivery"
        }
        if restaurant.deliveryTime != nil {
            cell.deliveryTimeLabel.text = "\(restaurant.deliveryTime!) mins"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantList.count
    }
}

