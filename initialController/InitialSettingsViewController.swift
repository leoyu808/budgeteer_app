//
//  InitialSettingsViewController.swift
//  budgeter
//
//  Created by Leo Yu on 11/3/21.
//

import UIKit

class InitialSettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var CurrencyTextField: UITextField!
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    let defaults = UserDefaults.standard
    
    var amt = 0
    var str = "%"
    
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    func updateNumTextField() -> String? {
        let number = Double(amt/100) + Double(amt%100)/100
        return numberFormatter.string(from: NSNumber(value: number))
    }
    func updateCharTextField() -> String? {
        if str.count == 1{
            return "%"
        }
        else{
            str = String(str.dropLast())
            str = String(str.dropLast())
            str += "%"
            return str
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row+1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = String(row+1)
    }
    
    
    @IBAction func enterTapped(_ sender: Any) {
        
        guard let desc = descriptionTextField.text?.dropLast() else{
            return
        }
        guard let num = pickerTextField.text else{
            return
        }
        
        let day = Int(num)
        let percent = Int(desc)
        
        if(amt != 0){
            defaults.set(Double(amt)/100, forKey: "monthlyIncome")
            defaults.set(percent, forKey: "savingPercent")
            defaults.set(day, forKey: "payDate")
            self.tabBarController!.tabBar.isHidden = false
            self.navigationController?.popToRootViewController(animated: true)
            self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
            defaults.set("No", forKey:"isFirstTime")
        }
        else{
            let alert = UIAlertController(title: "Reenter Monthly Income", message: "Monthly income is zero, please reenter the correct amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings"
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
        
        descriptionTextField.delegate = self
        pickerTextField.delegate = self
        CurrencyTextField.delegate = self
        CurrencyTextField.placeholder = updateNumTextField()
        pickerTextField.text = "1"
        self.hideKeyboardWhenTappedAround()
        
        
        // Do any additional setup after loading the view.
    }
}
extension InitialSettingsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let digit = Int(string) {
            if textField == CurrencyTextField{
                    amt = amt*10 + digit
                    textField.text = updateNumTextField()
                }
            else{
                if(Int((str.dropLast() + string)) ?? 0 > 100){
                    let alert = UIAlertController(title: "Reenter Number", message: "Percentage exceeds 100, please reenter your desired savings percentage.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    str = String(str.dropLast())
                    str += string
                    str += "%"
                    textField.text = str

                }
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
        return false

    }
}
