//
//  BuildingTableViewCell.swift
//  AXDLockers
//
//  Created by Paul Oprea on 29/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class BuildingTableViewCell: UITableViewCell {

    @IBOutlet weak var buildingUniqueNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var buildingImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buildingImage.tintColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
