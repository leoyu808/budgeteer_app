//
//  LearnViewController.swift
//  budgeter
//
//  Created by Leo Yu on 10/31/21.
//

import UIKit

class LearnViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let topics = ["Budgeting", "Debt", "Net Worth", "Credit", "Saving", "Investing", "Taxes", "Insurance"]
    let images = [UIImage(named: "Budgeting"), UIImage(named: "Debt"),UIImage(named: "NetWorth"), UIImage(named: "Credit"), UIImage(named: "Saving"), UIImage(named: "Investing"), UIImage(named: "Taxes"), UIImage(named: "Insurance")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = view.bounds.size.height/11.25
        
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        navigationController?.navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "learnCell") as! LearnViewCell
        
        cell.topicLabel.text = topics[indexPath.row]
        cell.imgView.image = images[indexPath.row]
        cell.backgroundColor = .systemGray5
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "nextLearnView") as! LearnViewController2
        nextViewController.title = topics[indexPath.row]
        show(nextViewController, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
