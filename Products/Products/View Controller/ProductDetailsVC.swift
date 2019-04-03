//
//  ProductDetailsVC.swift
//  Products
//
//  Created by Neethu Girija on 3/23/19.
//  Copyright © 2019 Neethu Girija. All rights reserved.
//

import UIKit



class ProductDetailsVC: UIViewController {
    var product: Products?
    
    @IBOutlet weak var productIDTextField: UITextField!
    @IBOutlet weak var productNameTextView: UITextView!
    @IBOutlet weak var productDescTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var mfgTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewContents()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    func updateViewContents() {
        guard let product = product else {
            print("Data unavailable")
            return
        }
        productIDTextField.text = product.productID
        productNameTextView.text = product.productName
        productDescTextView.text = product.descr
        priceTextField.text = product.price
        mfgTextField.text = formatDate(inString: product.mfgDate!)
    }

    //MARK: - Date formatter
    func formatDate(inString: String) -> (String) {
        //converting to date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.inputDateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = dateFormatter.date(from:inString)!
        
        //changind date format
        dateFormatter.dateFormat = Constants.displayDateFormat
        let newDateString = dateFormatter.string(from: date)
        return newDateString
    }
    
    //MARK: - Deleting the Product
    @IBAction func deleteProduct(_ sender: Any) {
        let alert = UIAlertController.init(title:"Delete", message: "Are you sure you want to delete?", preferredStyle: .alert)
        let actionForYes = UIAlertAction(title: "Yes", style: .default)  { _ in
            CoreDataManager.sharedManager.delete(self.product!)
            self.navigationController?.popViewController(animated: true)
        }
        let actionForNo = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alert.addAction(actionForYes)
        alert.addAction(actionForNo)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Prepare for Edit
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueIdUpdate {
            let modifyProductsVC = segue.destination as? ModifyProductsVC
            modifyProductsVC?.product = product
            modifyProductsVC?.delegate = self
        }
    }
}

//MARK: - Updating view after modify
extension ProductDetailsVC: ModifyProductDelegate {
    func updatedProduct(_ product: Products) {
        self.product = product
        updateViewContents()
    }
}
