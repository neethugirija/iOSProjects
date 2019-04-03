//
//  ModifyProductsVC.swift
//  Products
//
//  Created by Neethu Girija on 3/25/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import UIKit
//import Foundation
protocol ModifyProductDelegate : class {
    func updatedProduct(_ product:Products)
}

class ModifyProductsVC: UIViewController {
   
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var productID: UITextField!
    @IBOutlet weak var productName: UITextView!
    @IBOutlet weak var productDesc: UITextView!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var mfgDate: UITextField!
    
    weak var delegate:ModifyProductDelegate?
    
    var product:Products?
    var isInsert = true
    let datePicker = UIDatePicker()
    var selectedDate = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        //adjusting view frame while presenting & dismissing keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard Dismissal
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.scrollView.contentInset = UIEdgeInsets.zero
        }
    }
   
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - View Updations
    func updateView() {
        //to dismiss keyboard when scrolled
        scrollView.keyboardDismissMode = .onDrag
        
        //adding tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = true
        view.addGestureRecognizer(tapGesture)

        //date picker
        createDatePicker()
        
        //if add, do nothing
        guard let product = product else {
            return
        }
        //if modify, update values
        isInsert = false
        productID.text = product.productID
        productName.text = product.productName
        productDesc.text = product.descr
        price.text = product.price
        if let givenDateinString = product.mfgDate {
            mfgDate.text = formatDate(inString: givenDateinString)
            //setting date to datepicker
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Constants.inputDateFormat
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            let date = dateFormatter.date(from: givenDateinString)
            if date != nil {
                datePicker.date = date!
                selectedDate = dateFormatter.string(from: date!)
            }
        }
    }
    
    //MARK: - Date Picker
    func createDatePicker() {
        //adding date picker programmatically
        //Format Date
        datePicker.datePickerMode = .dateAndTime
        datePicker.maximumDate = Date()
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateSelected));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        mfgDate.inputAccessoryView = toolbar
        mfgDate.inputView = datePicker
    }
    
    @objc func dateSelected() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.inputDateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        selectedDate = dateFormatter.string(from: datePicker.date)
        mfgDate.text = formatDate(inString: selectedDate)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        self.view.endEditing(true)
    }
    
    //Date formatter
    func formatDate(inString: String) -> (String) {
        //converting to date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.inputDateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = Constants.inputDateFormat
        let date = dateFormatter.date(from:inString)!
        
        //changing date format
        dateFormatter.dateFormat = Constants.displayDateFormat
        let newDateString = dateFormatter.string(from: date)
        return newDateString
    }
    
    //MARK: - Save
    @IBAction func saveData() {
        if(isDataValid()) {
            if isInsert {
                CoreDataManager.sharedManager.saveProductWith(productName.text, productID.text!, productDesc.text, selectedDate, price.text!)
                self.navigationController?.popViewController(animated: true)
            } else {
                updateProductData()
            }
        }
    }
    
    //Updating previous View
    func updateProductData() {
        if let product = product {
            CoreDataManager.sharedManager.updateProductWith(productName.text!, productID.text!, productDesc.text!, selectedDate, price.text!, product)
            product.productID = productID.text
            product.productName = productName.text
            product.descr = productDesc.text
            product.mfgDate = selectedDate
            product.price = price.text
            delegate?.updatedProduct(product)
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController.init(title: "Alert", message: "Unable to Save", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    //Validations
    func isDataValid() -> Bool {
        
        let result = Validations.shared.validate(values: (type:.id , inputValue:  productID.text), (type:.name , inputValue:  productName.text), (type:.description , inputValue: productDesc.text), (type:.price , inputValue:  price.text), (type:.date , inputValue:  mfgDate.text))
        switch result {
        case .success:
            return true
        case .failure(let alertMessage):
            let alert = UIAlertController.init(title: "Alert", message: alertMessage.rawValue, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            return false
        }
    }
    
    //MARK: - Reset
    @IBAction func resetFields(){
        productID.text = ""
        productName.text = ""
        productDesc.text = ""
        mfgDate.text = ""
        price.text = ""
    }
}

//MARK: - UITextField & UITextView Delegates

extension ModifyProductsVC : UITextFieldDelegate, UITextViewDelegate {
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
