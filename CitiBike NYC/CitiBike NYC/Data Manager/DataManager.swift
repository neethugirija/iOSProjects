//
//  DataManager.swift
//  CitiBike NYC
//
//  Created by Neethu G on 2/17/19.
//  Copyright © 2019 Neethu G. All rights reserved.
//

import Foundation


class DataManager {

    func getJsonData (completionHandler:@escaping (_ result: CitiBikes?, _ error: Error?) -> Void) {
        guard let url = URL(string: Constants.jsonUrl) else {return}

        //retrieving data from json
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            print(dataResponse)

            //decoding data using JSONDecoder
            let decoder = JSONDecoder()
            do{
                let citibikes = try decoder.decode(CitiBikes.self, from: dataResponse)
                completionHandler(citibikes,nil)
            } catch let decodeError{
                print("Decode Error:\(decodeError)")
                completionHandler(nil,error)
            }
        }
        task.resume()

    }
}
