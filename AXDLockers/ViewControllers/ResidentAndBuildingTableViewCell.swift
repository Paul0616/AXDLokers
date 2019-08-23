//
//  ResidentAndBuildingTableViewCell.swift
//  AXDLockers
//
//  Created by Paul Oprea on 22/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class ResidentAndBuildingTableViewCell: UITableViewCell {

    @IBOutlet weak var residentNameLabel: UILabel!
    @IBOutlet weak var unitNumberLabel: UILabel!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
