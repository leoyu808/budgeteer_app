//
//  LearnViewController2.swift
//  budgeter
//
//  Created by Leo Yu on 10/31/21.
//

import UIKit
import SafariServices

class LearnViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private var topics: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 76.0
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true

        switch self.title{
        case "Investing":
            topics = ["Stocks", "Bonds", "Mutual Funds", "Exchange-Traded Funds", "Real Estate", "Commodoties", "Cryptocurrency"]
        case "Budgeting":
            topics = ["Budgeting Basics", "Evaluating Finances", "Creating a Budget", "50/30/20 Calculator"]
        case "Debt":
            topics = ["Secured vs. Unsecured", "Interest Rates", "Mortgage", "Car Loans", "Student Loans", "Personal Loans" , "Debt Payoff Calculator"]
        case "Net Worth":
            topics = ["What is Net Worth?", "Net Worth Importance", "Assets", "Liabilities", "Calculating Net Worth"]
        case "Credit":
            topics = ["What is Credit?", "Credit Score & Factors", "Bank Credit", "Line of Credit", "Improving Credit"]
        case "Saving":
            topics = ["Savings Account", "Certificates of Deposit", "Money Market Account", "Savings vs. Investment", "Passive Income Streams", "Retirement Savings"]
        case "Taxes":
            topics = ["Types of Taxes", "Filing Taxes", "Tax Credits", "Pretax Contribution", "Tax Calculator", "Minimizing Taxes"]
        case "Insurance":
            topics = ["Auto Insurance", "Home Insurance", "Health Insurance", "Life Insruance", "Renters' Insurance", "Multiline Insurance Plans"]
        default:
            self.navigationController?.popToRootViewController(animated: true)
        }
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "learnCell2") as! LearnViewCell2
        
        cell.topicLabel.text = topics[indexPath.row]
        cell.backgroundColor = .systemGray5
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.title{
        case "Investing":
            investing(index: indexPath.row)
        case "Budgeting":
            budgeting(index: indexPath.row)
        case "Debt":
            debt(index: indexPath.row)
        case "Net Worth":
            netWorth(index: indexPath.row)
        case "Credit":
            credit(index: indexPath.row)
        case "Saving":
            savings(index: indexPath.row)
        case "Taxes":
            taxes(index: indexPath.row)
        case "Insurance":
            insurance(index: indexPath.row)
        default:
            break
        }

//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "contentView") as! ContentViewController
//        nextViewController.title = topics[indexPath.row]
//        nextViewController.prevTitle = self.title!
//        self.navigationController?.pushViewController(nextViewController, animated: true)
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func investing(index: Int){
        var url = URL(string: "")
        switch topics[index]{
        case "Stocks":
            url = URL(string: "https://www.investopedia.com/terms/s/stock.asp")
        case "Bonds":
            url = URL(string: "https://www.investopedia.com/terms/b/bond.asp")
        case "Mutual Funds":
            url = URL(string: "https://www.investopedia.com/terms/m/mutualfund.asp")
        case "Exchange-Traded Funds":
            url = URL(string: "https://www.investopedia.com/terms/e/etf.asp")
        case "Real Estate":
            url = URL(string: "https://www.investopedia.com/terms/r/realestate.asp")
        case "Commodoties":
            url = URL(string: "https://www.investopedia.com/terms/c/commodity.asp")
        case "Cryptocurrency":
            url = URL(string: "https://www.investopedia.com/terms/c/cryptocurrency.asp")
        default:
            break
        }
        openURL(url: url!, enterReader: true)
    }
    
    func budgeting(index: Int){
        var enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "Budgeting Basics":
            url = URL(string: "https://www.practicalmoneyskills.com/learn/budgeting/budgeting_basics")
        case "Evaluating Finances":
            url = URL(string: "https://www.practicalmoneyskills.com/learn/budgeting/evaluating_your_finances")
        case "Creating a Budget":
            url = URL(string: "https://www.practicalmoneyskills.com/learn/budgeting/creating_a_budget")
        case "50/30/20 Calculator":
            url = URL(string: "https://www.nerdwallet.com/article/finance/nerdwallet-budget-calculator")
            enterReader = false
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }
    
    func debt(index: Int){
        var enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "Secured vs. Unsecured":
            url = URL(string: "https://www.investopedia.com/ask/answers/110614/what-difference-between-secured-and-unsecured-debts.asp")
        case "Interest Rates":
            url = URL(string: "https://www.investopedia.com/terms/i/interestrate.asp")
        case "Mortgage":
            url = URL(string: "https://www.investopedia.com/terms/m/mortgage.asp")
        case "Car Loans":
            url = URL(string: "https://www.investopedia.com/car-loan-calculator-5084761")
            enterReader = false
        case "Student Loans":
            url = URL(string: "https://www.investopedia.com/terms/s/student-debt.asp")
        case "Personal Loans":
            url = URL(string: "https://www.investopedia.com/personal-loan-5076027")
        case "Debt Payoff Calculator":
            url = URL(string: "https://www.investopedia.com/loan-calculator-5104934")
            enterReader = false
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }
    
    func netWorth(index: Int){
        let enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "What is Net Worth?":
            url = URL(string: "https://www.investopedia.com/terms/n/networth.asp")
        case "Net Worth Importance":
            url = URL(string: "https://www.investopedia.com/articles/pf/13/importance-of-knowing-your-net-worth.asp")
        case "Assets":
            url = URL(string: "https://www.investopedia.com/terms/a/asset.asp")
        case "Liabilities":
            url = URL(string: "https://www.investopedia.com/terms/l/liability.asp")
        case "Calculating Net Worth":
            url = URL(string: "https://www.investopedia.com/articles/pf/13/calculating-your-tangible-net-worth.asp")
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }
    
    func credit(index: Int){
        let enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "What is Credit?":
            url = URL(string: "https://www.investopedia.com/terms/c/credit.asp")
        case "Credit Score & Factors":
            url = URL(string: "https://www.investopedia.com/terms/c/credit_score.asp")
        case "Bank Credit":
            url = URL(string: "https://www.investopedia.com/terms/b/bank-credit.asp")
        case "Line of Credit":
            url = URL(string: "https://www.investopedia.com/terms/l/lineofcredit.asp")
        case "Improving Credit":
            url = URL(string: "https://www.investopedia.com/how-to-improve-your-credit-score-4590097")
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }
    
    func savings(index: Int){
        let enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "Savings Account":
            url = URL(string: "https://www.investopedia.com/terms/s/savingsaccount.asp")
        case "Certificates of Deposit":
            url = URL(string: "https://www.investopedia.com/terms/c/certificateofdeposit.asp")
        case "Money Market Account":
            url = URL(string: "https://www.investopedia.com/terms/m/moneymarketaccount.asp")
        case "Savings vs. Investment":
            url = URL(string: "https://www.investopedia.com/articles/investing/022516/saving-vs-investing-understanding-key-differences.asp")
        case "Passive Income Streams":
            url = URL(string: "https://www.investopedia.com/terms/p/passiveincome.asp")
        case "Retirement Savings":
            url = URL(string: "https://www.investopedia.com/terms/r/retirement-planning.asp")
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }
    
    func taxes(index: Int){
        var enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "Types of Taxes":
            url = URL(string: "https://taxfoundation.org/the-three-basic-tax-types/")
        case "Filing Taxes":
            url = URL(string: "https://www.investopedia.com/ask/answers/051415/what-are-different-ways-i-can-file-my-income-tax-return.asp")
        case "Tax Credits":
            url = URL(string: "https://www.irs.gov/credits-deductions-for-individuals")
            enterReader = false
        case "Pretax Contribution":
            url = URL(string: "https://www.investopedia.com/terms/p/pretaxcontribution.asp")
        case "Tax Calculator":
            url = URL(string: "https://turbotax.intuit.com/tax-tools/calculators/taxcaster/")
            enterReader = false
        case "Minimizing Taxes":
            url = URL(string: "https://www.investopedia.com/ask/answers/040715/what-are-some-ways-minimize-tax-liability.asp")
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }
    
    func insurance(index: Int){
        let enterReader = true
        var url = URL(string: "")
        switch topics[index]{
        case "Auto Insurance":
            url = URL(string: "https://www.investopedia.com/terms/a/auto-insurance.asp")
        case "Home Insurance":
            url = URL(string: "https://www.investopedia.com/terms/h/homeowners-insurance.asp")
        case "Health Insurance":
            url = URL(string: "https://www.investopedia.com/terms/h/healthinsurance.asp")
        case "Life Insruance":
            url = URL(string: "https://www.investopedia.com/car-loan-calculator-5084761")
        case "Renters' Insurance":
            url = URL(string: "https://www.investopedia.com/terms/r/renters-insurance.asp")
        case "Multiline Insurance Plans":
            url = URL(string: "https://www.investopedia.com/ask/answers/08/multiline-insurance.asp")
        default:
            break
        }
        openURL(url: url!, enterReader: enterReader)
    }

    func openURL (url: URL, enterReader: Bool){
        let alert = UIAlertController(title: "Open Link in Safari", message: "You are about to open a new link in Safari. Would you like to proceed?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { action in
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = enterReader
            let vc = SFSafariViewController(url: url, configuration: config)
            self.present(vc, animated: true)
                
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
