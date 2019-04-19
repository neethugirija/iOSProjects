//
//  APIServices.swift
//  Door Dash
//
//  Created by Neethu Girija on 4/17/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import Foundation
import CoreLocation

enum Result<T> {
    case Error(String)
    case Success([Restaurant])
}
class APIServices {
    
    func getData(for location: CLLocation, result: @escaping(Result<[Restaurant]>) -> Void){
        let url = URL(string: "https://api.doordash.com/v1/store_search/?lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)")
        
        guard let jsonUrl = url else{
            return result(.Error("Invalid URL"))
        }
        let task = URLSession.shared.dataTask(with: jsonUrl) { (data, response, error) in
            if error != nil {
                return result(.Error("Response Error"))
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    return result(.Error("Invalid Response"))
                }
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let jsonArray = json as? [[String:Any]] {
                        var restaurantList = [Restaurant]()
                        //updating restaurant list
                        for aRestaurant in jsonArray {
                            let restaurant = Restaurant()
                            restaurant.name = aRestaurant["name"] as? String
                            restaurant.deliveryFee = aRestaurant["delivery_fee"] as? Int
                            restaurant.deliveryTime = aRestaurant["asap_time"] as? Int
                            restaurant.id = aRestaurant["id"] as? String
                            restaurant.description = aRestaurant["description"] as? String
                            restaurant.imageUrl = aRestaurant["cover_img_url"] as? String
                            restaurantList.append(restaurant)
                        }
                        //updating view controller asynchronously
                        DispatchQueue.main.async {
                            return result(.Success(restaurantList))
                        }
                    }
                    
                }catch(let error) {
                    print("Parse error:\(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}
