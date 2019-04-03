//
//  Validations.swift
//  Products
//
//  Created by Neethu Girija on 4/1/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import Foundation

enum Valid {
    case success
    case failure(AlertMessages)
}

enum ValidationType {
    case id
    case name
    case description
    case price
    case date
}

enum RegEx: String {
    case currency = "\\$[0-9]+\\.*[0-9]{0,2}"
}

enum AlertMessages : String {
    case nameEmpty = "Please enter Product Name"
    case priceEmpty = "Please enter Product Price"
    case descriptionEmpty = "Please enter Product Description"
    case dateEmpty = "Please enter date of manufacture"
    case idEmpty = "Please enter Product ID"
    case invalidPrice = "Invalid Price - Accepted format: $XX.XX"
    case invalidName = "Invalid Name - - Atleast 4 characters long"
    case invalidDesc = "Invalid Description - - Atleast 4 characters long"
    case invalidID = "Invlaid ID - Atleast 4 characters long"
    case unknownError = "Unknown Error"
}


class Validations: NSObject {

    public static let shared = Validations()
    private override init() {}

    func validate(values: (type: ValidationType, inputValue: String?)...) -> Valid {
        for valueToBeChecked in values {
            switch valueToBeChecked.type {
            case .id:
                guard let text = valueToBeChecked.inputValue else {
                    return .failure(.idEmpty)
                }
                if text.count < 4 {
                    return .failure(.invalidID)
                }
            case .name:
                guard let text = valueToBeChecked.inputValue else {
                    return .failure(.nameEmpty)
                }
                if text.count < 4 {
                    return .failure(.invalidName)
                }
                
            case .description:
                guard let text = valueToBeChecked.inputValue else {
                    return .failure(.descriptionEmpty)
                }
                if text.count < 4 {
                    return .failure(.invalidDesc)
                }
            case .price:
                if let result = isValidString((text: valueToBeChecked.inputValue, regex: .currency, emptyAlert: .priceEmpty, invalidAlert: .invalidPrice)){
                    return result
                }
            case .date:
                guard valueToBeChecked.inputValue != nil else {
                    return .failure(.dateEmpty)
                }
            }
        }
        return .success
    }
    
        
        func isValidString(_ input: (text: String?, regex: RegEx, emptyAlert: AlertMessages, invalidAlert: AlertMessages)) -> Valid? {
        if let text = input.text {
            if text == "" {
                return .failure(input.emptyAlert)
            }
            if isValidRegEx(text, input.regex) != true {
                return .failure(input.invalidAlert)
            } else {
                return .success
            }
        } else {
            return .failure(input.emptyAlert)
        }
    }
    
    fileprivate func isValidRegEx(_ testStr: String, _ regex: RegEx) -> Bool {
        let stringTest = NSPredicate(format:"SELF MATCHES %@", regex.rawValue)
        let result = stringTest.evaluate(with: testStr)
        return result
    }
}
