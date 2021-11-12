//
//  AddExpenseViewController.swift
//  BalancedBudget
//
//  Created by Leo Yu on 10/26/21.
//

import UIKit
import CloudKit

class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var CurrencyTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var segmentPicker: UISegmentedControl!
    
    var recur = false
    var amt = 0
    var str = ""
    
    let pickOptions = ["Housing", "Transportation", "Food", "Utilities", "Insurance", "Medical", "Entertainment", "Personal", "Miscellaneous"]
    private var models = [ExpenseItem]()
    
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        
        descriptionTextField.delegate = self
        pickerTextField.delegate = self
        CurrencyTextField.delegate = self
        CurrencyTextField.placeholder = updateNumTextField()
        self.hideKeyboardWhenTappedAround()
        
        
        
        title = "Add New Expense"

        // Do any additional setup after loading the view.
    }
    
    func updateNumTextField() -> String? {
        let number = Double(amt/100) + Double(amt%100)/100
        return numberFormatter.string(from: NSNumber(value: number))
    }
    func updateCharTextField() -> String? {
        if str.isEmpty{
            return ""
        }
        else{
            str = String(str.dropLast())
            return str
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOptions[row]
    }
    
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentPicker.selectedSegmentIndex
            {
            case 0:
                recur = false
            case 1:
                recur = true
            default:
                break
            }

    }
    
    @IBAction func enterTapped(_ sender: Any) {
        
        guard let desc = descriptionTextField.text else{
            return
        }
        guard let cat = pickerTextField.text else{
            return
        }
        
        
        ExpensesViewController().createItem(description: desc, date: datePicker.date, amount: Double(amt)/100, category: cat, recur: recur)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension AddExpenseViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            if textField == CurrencyTextField{
                    amt = amt*10 + digit
                    textField.text = updateNumTextField()
                }
            else{
                str += string
                textField.text = str
            }
            
        }
        else if string == ""{
            if textField == CurrencyTextField{
                amt = amt/10
                textField.text = updateNumTextField()
            }
            else{
                textField.text = updateCharTextField()
            }
        }
        else{
            str += string
            descriptionTextField.text = str
        }
        return false
    }
}


extension String {
    
    func isDouble() -> Bool {

        if  Double(self) != nil {
            return true
        }

        return false
    }

}

