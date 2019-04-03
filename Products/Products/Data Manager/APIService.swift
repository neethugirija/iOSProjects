//
//  APIService.swift
//  Pharmacy Inventory
//
//  Created by Neethu Girija on 3/21/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import UIKit

enum Response<T> {
    case Error(String)
    case Success([[String:AnyObject]])
}

class APIService: NSObject {
    lazy var url = URL(string: Constants.jsonURL)!
    
    
    func getInventoryWith(result: @escaping(Response<[[String:AnyObject]]>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil  else{
                return result(.Error(error!.localizedDescription))
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode != 200 {
                    return result(.Error("Failed to get data"))
                }
            }
            guard let data = data else {
                return result(.Error("No data retrieved"))
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [[String:AnyObject]] {
                    DispatchQueue.main.async {
                        return result(.Success(json))
                    }
                }
                
            } catch let error{
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
}
