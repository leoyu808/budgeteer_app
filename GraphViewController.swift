//
//  GraphViewController.swift
//  budgeter
//
//  Created by Leo Yu on 10/29/21.
//

import Charts
import UIKit
import Foundation

struct Categories {
    let category: String
    let total: Double
    let img: UIImage
    let options: [Expense]
    var isOpened: Bool = false
    
    init(category: String, total: Double, img: UIImage, options: [Expense], isOpened: Bool = false){
        self.category = category
        self.total = total
        self.img = img
        self.options = options
        self.isOpened = isOpened
    }
}

struct Expense{
    let amount: Double
    let name: String
    
    init(amount: Double, name: String){
        self.amount = amount
        self.name = name
    }
}

class GraphViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var segmentPicker: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    private var images = [UIColor(named: "Azure")!.image(), UIColor(named: "Jade")!.image(), UIColor(named: "Turquoise")!.image(), UIColor(named: "Yellow")!.image(),UIColor(named: "Coral")!.image(), UIColor(named: "DarkBlue")!.image(), UIColor(named: "Lavender")!.image(), UIColor(named: "Rose")!.image(), UIColor(named: "LightYellow")!.image(), UIColor(named: "Orange")!.image(), UIColor(named: "Purple")!.image()]

    private var catExpenses = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var models: [ExpenseItem] = []
    private var catSums: [Double] = []
    private var monthSums: [Double] = []
    private var selected: Int = 0
    let defaults = UserDefaults.standard
    let pickOptions = ["Excess Funds", "Savings", "Housing", "Transportation", "Food", "Utilities", "Insurance", "Medical", "Entertainment", "Personal", "Miscellaneous"]
    let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let monthImage = [UIImage(named: "january")!, UIImage(named: "february")!, UIImage(named: "march")!, UIImage(named: "april")!, UIImage(named: "may")!, UIImage(named: "june")!, UIImage(named: "july")!, UIImage(named: "august")!, UIImage(named: "september")!, UIImage(named: "october")!, UIImage(named: "november")!, UIImage(named: "december")!]
    
    private var pastFour = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pieChart.delegate = self
        barChart.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 10
        tableView.layer.masksToBounds = true
        
        models = ExpensesViewController().getNewItems(days: 0, months: -1, years: 0)
        
        pieChart.layer.cornerRadius = 10
        pieChart.layer.masksToBounds = true
        pieChart.backgroundColor = .systemGray5
        pieChart.holeColor = .systemGray5
        pieChart.drawEntryLabelsEnabled = false
        setupBarChart()
        selected = 0
        
        tableView.rowHeight = 60
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(selected == 0){
            pieChart.isHidden = false
            barChart.isHidden = true
            if(defaults.integer(forKey: "payDate") >= Date().dayNumberOfWeek()!){
                models = ExpensesViewController().getNewItems(days: defaults.integer(forKey: "payDate") - Date().startOfDay.dayNumberOfWeek()!, months: -1, years: 0)
            }
            else{
                models = ExpensesViewController().getNewItems(days: defaults.integer(forKey: "payDate") - Date().startOfDay.dayNumberOfWeek()!, months: 0, years: 0)
            }
            pieChart.highlightValue(nil)
            pieChart.centerAttributedText = NSAttributedString(string: " ")
            periodPieChart()
        }
        else if(selected == 1){
            pieChart.isHidden = false
            barChart.isHidden = true
            models = ExpensesViewController().getNewItems(days: -7, months: 0, years: 0)
            pieChart.highlightValue(nil)
            pieChart.centerAttributedText = NSAttributedString(string: " ")
            periodPieChart()
        }
        else{
            barChart.isHidden = false
            monthBarChart()
        }
    }
    
    func periodPieChart() {
        
        setupPieChartTableItems()
        
        var entries = [PieChartDataEntry]()
        
        for x in 0...(catSums.count - 1){
            if(catSums[x] > 0){
                entries.append(PieChartDataEntry(value: (catSums[x]),label: pickOptions[x]))
            }
            else{
                entries.append(PieChartDataEntry(value: 0, label: ""))
            }
        }
        
        let set = PieChartDataSet(entries: entries)
        let colors = [UIColor(named: "Azure"), UIColor(named: "Jade"), UIColor(named: "Turquoise"), UIColor(named: "Yellow"),UIColor(named: "Coral"), UIColor(named: "DarkBlue"), UIColor(named: "Lavender"), UIColor(named: "Rose"), UIColor(named: "LightYellow"), UIColor(named: "Orange"), UIColor(named: "Purple")]
        set.colors = colors as! [NSUIColor]
        set.drawValuesEnabled = false

        let data = PieChartData(dataSet: set)
        pieChart.data = data
        pieChart.legend.enabled = false
        
        pieChart.notifyDataSetChanged()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func monthBarChart() {
        setupBarChart()
        setupBarChartTableItems()

        var dataEntries = [BarChartDataEntry]()
        for i in 0..<monthSums.count {
          let dataEntry = BarChartDataEntry(x: Double(i), y: monthSums[i])
          dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries)
        chartDataSet.colors = [UIColor(named: "Azure")!]
        chartDataSet.drawValuesEnabled = false
        let chartData = BarChartData(dataSet: chartDataSet)
        
        barChart.data = chartData
        barChart.notifyDataSetChanged()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func calcCategories() {
        
        catSums = []
        
        var houseSum = 0.0
        var transSum = 0.0
        var foodSum = 0.0
        var utilSum = 0.0
        var insSum = 0.0
        var medSum = 0.0
        var entSum = 0.0
        var perSum = 0.0
        var miscSum = 0.0
        
        for item in models{
            switch item.expenseCat{
            case "Housing":
                houseSum += item.expenseAmt
            case "Transportation":
                transSum += item.expenseAmt
            case "Food":
                foodSum += item.expenseAmt
            case "Utilities":
                utilSum += item.expenseAmt
            case "Insurance":
                insSum += item.expenseAmt
            case "Medical":
                medSum += item.expenseAmt
            case "Entertainment":
                entSum += item.expenseAmt
            case "Personal":
                perSum += item.expenseAmt
            case "Miscellaneous":
                miscSum += item.expenseAmt
            default:
                miscSum += 0.0
            }
        }
        let tempCatSums = [houseSum, transSum, foodSum, utilSum, insSum, medSum, entSum, perSum, miscSum]
        
        
        var totalSums = 0.0
        for x in tempCatSums{
            
            catSums.append(x)
            totalSums += x
            
        }
        if(selected == 0){
            let savings = Double(defaults.integer(forKey: "savingPercent"))/100.0  * defaults.double(forKey: "monthlyIncome")
            let remaining = (defaults.double(forKey: "monthlyIncome") - totalSums)
            if(savings <= remaining){
                catSums.insert(savings, at: 0)
                catSums.insert(remaining - savings, at: 0)
            }
            else if (remaining > 0){
                catSums.insert(remaining, at: 0)
                catSums.insert(0.0, at: 0)
            }
            else {
                catSums.insert(0.0, at: 0)
                catSums.insert(0.0, at: 0)
            }
        }
        else {
            catSums.insert(0.0, at: 0)
            catSums.insert(0.0, at: 0)
        }
    }
    @IBAction func indexChanged(_ sender: UISegmentedControl) {
        switch segmentPicker.selectedSegmentIndex
            {
            case 0:
            pieChart.isHidden = false
            barChart.isHidden = true
            selected = 0
            if(defaults.integer(forKey: "payDate") >= Date().startOfDay.dayNumberOfWeek()!){
            models = ExpensesViewController().getNewItems(days: defaults.integer(forKey: "payDate") - Date().startOfDay.dayNumberOfWeek()!, months: -1, years: 0)
            }
            else{
            models = ExpensesViewController().getNewItems(days: defaults.integer(forKey: "payDate") - Date().startOfDay.dayNumberOfWeek()!, months: 0, years: 0)
            }
            pieChart.highlightValue(nil)
            pieChart.centerAttributedText = NSAttributedString(string: " ")
            periodPieChart()
            case 1:
            selected = 1
            pieChart.isHidden = false
            barChart.isHidden = true
            models = ExpensesViewController().getNewItems(days: -7, months: 0, years: 0)
            pieChart.highlightValue(nil)
            pieChart.centerAttributedText = NSAttributedString(string: " ")
            periodPieChart()
            case 2:
            selected = 2
            barChart.isHidden = false
            monthBarChart()
            default:
                break
            }

    }
    
    func calcSums() -> Double{
        var sum = 0.0
        for item in models{
            sum += item.expenseAmt
        }
        return sum
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
        return catExpenses.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = catExpenses[section]
        
        if section.isOpened{
            return section.options.count + 1
        }
        else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MyTableCell
            cell.imgView.layer.cornerRadius = 5
            cell.layer.cornerRadius = 5
            cell.layer.masksToBounds = true
            cell.backgroundColor = .systemGray5
            
            cell.catLabel.text = catExpenses[indexPath.section].category
            cell.amtLabel.text = "$" + String(format: "%.2f", catExpenses[indexPath.section].total)
            cell.imgView.image = catExpenses[indexPath.section].img
            
            return cell
        }
        else{
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "cell2") as! MyTableCell2
            cell2.layer.cornerRadius = 5
            cell2.layer.masksToBounds = true
            cell2.backgroundColor = UIColor(named: "cellcolor")
            
            var text = " +   " + catExpenses[indexPath.section].options[indexPath.row - 1].name
            let amtTxt = "$" + String(format: "%.2f", catExpenses[indexPath.section].options[indexPath.row - 1].amount)
            for _ in 0...(Int(round(tableView.bounds.size.width/10)-1)-(text.count + amtTxt.count)){
                text += " "
            }
            text += amtTxt
            print(tableView.bounds.size.width)
            print(Int((tableView.bounds.size.width/10)-1))
            cell2.catLabel.text = text
            
            return cell2
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        catExpenses[indexPath.section].isOpened = !catExpenses[indexPath.section].isOpened
        tableView.reloadSections([indexPath.section], with: .none)
    }
    
    func returnAllItems() -> [ExpenseItem] {
        var temp = [ExpenseItem]()
        do{
            temp = try context.fetch(ExpenseItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch{
            
        }
        return temp
    }
    
    func setupPieChartTableItems(){
        calcCategories()
        catExpenses = []
        var loops = 0
        for string in pickOptions{
            var options: [Expense] = []
            for item in models{
                if item.expenseCat == string{
                    options.append(Expense(amount: item.expenseAmt, name: item.expenseDesc!))
                }
            }
            if(catSums[loops] != 0.0){
                catExpenses.append(Categories(category: string, total: catSums[loops], img: images[loops], options: options))
            }
            loops += 1
        }
    }
    
    func setupBarChartTableItems(){
        models = returnAllItems()
        monthSums = []
        catExpenses = []
        var dateComponent = DateComponents()
        dateComponent.month = -3
        dateComponent.day = -(Date().dayNumberOfWeek()!-1)
        dateComponent.year = 0
        
        var months = Calendar.current.date(byAdding: dateComponent, to: Date().startOfDay)!
        var loops = 0
        while months < Date(){
            var options: [Expense] = []
            var sum = 0.0
            var newDateComponent = DateComponents()
            newDateComponent.month = 1
            let temp = Calendar.current.date(byAdding: newDateComponent, to: months)!
            for item in models{
                if(item.expenseDate! >= months && item.expenseDate! <= temp){
                    sum += item.expenseAmt
                    options.append(Expense(amount: item.expenseAmt, name: item.expenseDesc!))
                }
            }
            months = temp
            monthSums.append(sum)
            catExpenses.append(Categories(category: pastFour[loops], total: sum, img: pastFourIcons()[loops], options: options))
            loops += 1
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if chartView is PieRadarChartViewBase {
            guard let label = entry.value(forKey: "label") as? String else{
                return
            }
            var amt = entry.value(forKey: "value") as! Double
            if(selected == 0){
                amt = amt/defaults.double(forKey: "monthlyIncome")*100
            }
            else{
                amt = amt/calcSums()*100
            }
            let finAmt = amt.rounded(toPlaces: 2)
            var centerText: String
            
            if finAmt.truncatingRemainder(dividingBy: 0.1) < 0.099{
                centerText = """
                \(label)
                \(finAmt)%
                """
            }
            else{
                centerText = """
                \(label)
                \(finAmt)0%
                """
            }
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(named: "centertext") ?? UIColor.black,
                .font: UIFont.systemFont(ofSize: 15),
                .paragraphStyle: titleParagraphStyle
            ]
            let myAttrString = NSAttributedString(string: centerText, attributes: attributes)
            pieChart.centerAttributedText = myAttrString
        }
    }
    func setupBarChart(){
        barChart.layer.cornerRadius = 10
        barChart.layer.masksToBounds = true
        barChart.backgroundColor = .systemGray5
        barChart.extraBottomOffset = 10
        barChart.extraTopOffset = 20
        barChart.pinchZoomEnabled = false
        barChart.doubleTapToZoomEnabled = false
        pastFour = pastFourMonths()
        
        let rightAxis = barChart.rightAxis
        rightAxis.enabled = false
        
        let xaxis = barChart.xAxis
        xaxis.labelPosition = .bottom
        xaxis.granularity = 1
        xaxis.valueFormatter = IndexAxisValueFormatter(values:pastFour)
        xaxis.drawGridLinesEnabled = false
        let yaxis = barChart.leftAxis
        yaxis.axisMinimum = 0.0
        yaxis.drawGridLinesEnabled = false
        
        let legend = barChart.legend
        legend.enabled = false
        barChart.notifyDataSetChanged()
    }
    func pastFourMonths() -> [String]{
        var tempArray = [String]()
        for a in (Date().startOfDay.monthNumber()!-4)..<(Date().startOfDay.monthNumber()!){
            var x = a
            switch x{
            case -3:
                x = 9
            case -2:
                x = 10
            case -1:
                x = 11
            default:
                x = a
            }
            tempArray.append(monthNames[x])
        }
        return tempArray
    }
    func pastFourIcons() -> [UIImage] {
        var tempArray = [UIImage]()
        for a in (Date().startOfDay.monthNumber()!-4)..<(Date().startOfDay.monthNumber()!){
            var x = a
            switch x{
            case -3:
                x = 9
            case -2:
                x = 10
            case -1:
                x = 11
            default:
                x = a
            }
            tempArray.append(monthImage[x])
        }
        return tempArray
    }
 }
extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
extension Date{
    func dayNumberOfWeek() -> Int? {
        let timeZone = TimeZone(abbreviation: "EDT")
        let component =  Calendar.current.dateComponents(in: timeZone!, from: self)
        return  component.day
    }
    
    func monthNumber() -> Int? {
        let timeZone = TimeZone(abbreviation: "EDT")
        let component =  Calendar.current.dateComponents(in: timeZone!, from: self)
        return  component.month
    }
}
