//
//  MyTableCell.swift
//  budgeter
//
//  Created by Leo Yu on 10/30/21.
//

import UIKit

class MyTableCell: UITableViewCell {
    
    @IBOutlet weak var amtLabel: UILabel!
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
