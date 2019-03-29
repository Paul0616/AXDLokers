//
//  ResidentTableViewCell.swift
//  AXDLockers
//
//  Created by Paul Oprea on 28/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class ResidentTableViewCell: UITableViewCell {

    @IBOutlet weak var residentNameLabel: UILabel!
    @IBOutlet weak var suiteNumberLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
