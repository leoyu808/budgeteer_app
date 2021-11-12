//
//  ExpensesViewController.swift
//  BalancedBudget
//
//  Created by Leo Yu on 10/26/21.
//

import UIKit

class ExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var totalExpenses: UITextView!
    @IBOutlet weak var datePickerTextField: UITextField!
    @IBOutlet weak var firstDatePicker: UIDatePicker!
    @IBOutlet weak var secondDatePicker: UIDatePicker!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var models = [ExpenseItem]()
    private var reccurringItems = [ExpenseItem]()
    
    let dateRanges = ["Past Month", "Past Week", "Custom"]

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    let defaults = UserDefaults.standard
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(Date().startOfDay.dayNumberOfWeek() != (defaults.object(forKey: "lastAccessed") as! Date).dayNumberOfWeek()){
            updateReccurring()
        }
        getAllItems()
        updateModels()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFirstTime()
        
        title = "Expenses"
        navigationItem.largeTitleDisplayMode = .always
        
        defaults.set(Date().startOfDay, forKey: "lastAccessed")
        let pickerView = UIPickerView()
        pickerView.delegate = self
        datePickerTextField.inputView = pickerView
        datePickerTextField.text = "Past Month"
        datePickerTextField.delegate = self
        totalExpenses.delegate = self
        view.addSubview(tableView)
        getAllItems()
        
        firstDatePicker.isHidden = true
        firstDatePicker.datePickerMode = UIDatePicker.Mode.date
        secondDatePicker.isHidden = true
        secondDatePicker.datePickerMode = UIDatePicker.Mode.date
        
        let newItems = getNewItems(days: -1, months: -1, years: 0)
        models = newItems
        reloadData(items: newItems)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0.0, y: 247.5, width: view.bounds.size.width, height: view.bounds.size.height-330)
        print(view.bounds.size.width)
        tableView.backgroundColor = .systemGray6
        tableView.allowsSelection = false
        tabBarController?.tabBar.backgroundColor = UIColor(named: "tabbarcolor")
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        tabBarController?.tabBar.tintColor = UIColor(named: "selectedItem")
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    func customDateChange() -> [ExpenseItem] {
        getAllItems()
        
        let date2 = secondDatePicker.date
        firstDatePicker.maximumDate = date2
        
        var newModels = [ExpenseItem]()

        let date1 = firstDatePicker.date

        for item in models{
            if item.expenseDate! >= date1.startOfDay && item.expenseDate! <= date2.endOfDay {
                newModels.append(item)
            }
        }
        return newModels
    }
    
    func updateModels(){
        var newItems: [ExpenseItem]
        if(datePickerTextField.text == "Past Month"){
            newItems = getNewItems(days: 0, months: -1, years: 0)
        }
        else if datePickerTextField.text == "Past Week" {
            newItems = getNewItems(days: -7, months: 0, years: 0)
        }
        else{
            newItems = customDateChange()
        }
        models = newItems
        reloadData(items: newItems)

    }
    
    func isFirstTime(){
        if !(defaults.string(forKey: "isFirstTime") == "No") {
            print("Hi")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "initialvc") as! InitialViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            self.tabBarController!.tabBar.isHidden = true
        }
    }
    
    func getRecurringItems(){
        reccurringItems = []
        var currentModels = [ExpenseItem]()
        var uniqueItems = [ExpenseItem]()
        do{
             currentModels = try context.fetch(ExpenseItem.fetchRequest())
        }
        catch{
            
        }
        for i in currentModels{
            if(i.expenseRecurring){
                reccurringItems.append(i)
            }
        }
        for a in reccurringItems{
            var instances = 0
            for b in reccurringItems{
                if(a.expenseDesc == b.expenseDesc){
                    instances += 1
                }
            }
            if instances == 1{
                uniqueItems.append(a)
            }
            else{
                uniqueItems.removeAll { value in
                    return value.expenseDesc == a.expenseDesc
                }
                uniqueItems.append(a)
            }
        }
        reccurringItems = uniqueItems
    }
    
    func updateReccurring(){
        getRecurringItems()
        
        while (defaults.object(forKey: "lastAccessed") as! Date) < Date().startOfDay {
            self.defaults.set(Calendar.current.date(byAdding: .day, value: 1, to: self.defaults.object(forKey: "lastAccessed") as! Date)!, forKey:"lastAccessed")
            for item in reccurringItems{
                if(item.expenseDate?.startOfDay.dayNumberOfWeek() == (defaults.object(forKey: "lastAccessed") as! Date).dayNumberOfWeek()){
                    createItem(description: item.expenseDesc!, date: (defaults.object(forKey: "lastAccessed") as! Date), amount: item.expenseAmt, category: item.expenseCat!, recur: item.expenseRecurring)
                }
            }
        }
    }
    
    @IBAction func pressed(_ sender: Any) {
        reloadData(items: models)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
            self.deleteItem(item: self.models[indexPath.row])
            self.getAllItems()
            self.updateModels()

        }

        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { action, indexPath in
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "editexpensevc") as! EditExpenseViewController
            nextViewController.models = self.models
            nextViewController.index = indexPath.row
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        editAction.backgroundColor = .systemOrange
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.backgroundColor = .systemGray6
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        let strDate = dateFormatter.string(from: model.expenseDate!) + ": "
        var newStr = strDate
        
        for _ in 0..<(10-strDate.count){
            newStr += " "
        }
            
        var str = newStr + model.expenseDesc!
        let money = "$" + String(format:"%.2f", model.expenseAmt)
        let totalLength = str.count + money.count
        
        for _ in 0...(Int((view.bounds.size.width/10)-1)-totalLength) {
            str += " "
        }
        
        str += money
        
        cell.textLabel?.font = UIFont(name:"Courier", size: 15)
        cell.textLabel?.text = str
        
        return cell
        
    }
    
    func getAllItems(){
        do{
            models = try context.fetch(ExpenseItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            models.sort{
                $0.expenseDate! > $1.expenseDate!
            }
        }
        catch{
            
        }
    }
    
    func updateItem(item: ExpenseItem, newDes: String, newDate: Date, newAmt: Double, newCat: String, recur: Bool){
        item.expenseDesc = newDes
        item.expenseDate = newDate
        item.expenseAmt = newAmt
        item.expenseCat = newCat
        item.expenseRecurring = recur
        do{
            try context.save()
            getAllItems()
        }
        catch{
            
        }
    }
    
    func deleteItem(item: ExpenseItem){
        context.delete(item)
        
        do{
            try context.save()
        }
        catch{
            
        }
    }
    
    func deleteAllItems(){
        getAllItems()
        
        for myItem in models{
            deleteItem(item: myItem)
        }
    }
    
    func createItem(description: String, date: Date, amount: Double, category: String, recur: Bool){
        let newItem = ExpenseItem(context: context)
        newItem.expenseDesc = description
        newItem.expenseDate = date
        newItem.expenseAmt = amount
        newItem.expenseCat = category
        newItem.expenseRecurring = recur
        
        do{
            try context.save()
            getAllItems()
        }
        catch{
            
        }
    }
    
    func getNewItems(days: Int, months: Int, years: Int) -> [ExpenseItem] {
        getAllItems()
        let date2 = Date().endOfDay
        var newModels = [ExpenseItem]()

        var dateComponent = DateComponents()

        dateComponent.month = months
        dateComponent.day = days
        dateComponent.year = years

        let date1 = Calendar.current.date(byAdding: dateComponent, to: date2)!

        for item in models{
            if item.expenseDate! >= date1.startOfDay && item.expenseDate! <= date2 {
                newModels.append(item)
            }
        }
        return newModels

    }
    
    func getNewItems(date: Date) -> [ExpenseItem] {
        getAllItems()
        let date2 = Date()
        var newModels = [ExpenseItem]()
        let date1 = date.startOfDay

        for item in models{
            if item.expenseDate! >= date1 && item.expenseDate! <= date2 {
                newModels.append(item)
            }
        }
        return newModels
    }
    
    @IBAction func firstDateChange(_ sender: UIDatePicker) {
        models = customDateChange()
        reloadData(items: models)
    }
    
    @IBAction func secondDateChange(_ sender: UIDatePicker) {
        models = customDateChange()
        reloadData(items: models)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateRanges.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateRanges[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        datePickerTextField.text = dateRanges[row]
        if(dateRanges[row] == "Custom"){
            firstDatePicker.isHidden = false
            secondDatePicker.isHidden = false
            models = customDateChange()
            reloadData(items: models)
        }
        else if(dateRanges[row] == "Past Week"){
            firstDatePicker.isHidden = true
            secondDatePicker.isHidden = true
            getAllItems()
            
            let newItems = getNewItems(days: -8, months: 0, years: 0)
            models = newItems
            reloadData(items: newItems)
        }
        else{
            firstDatePicker.isHidden = true
            secondDatePicker.isHidden = true
            getAllItems()
            let newItems = getNewItems(days: -1, months: -1, years: 0)
            models = newItems
            reloadData(items: newItems)
            
        }
    }
    
    func reloadData( items : [ExpenseItem]) {
        
        var sum = 0.0
        for item in items{
            sum += item.expenseAmt
        }

        let str = String(format:"%.2f", sum)
        
        totalExpenses.text = "$" + str
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension Date {

    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
   }

    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
}
