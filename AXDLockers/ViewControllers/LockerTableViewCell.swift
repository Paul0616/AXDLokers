//
//  LockerTableViewCell.swift
//  AXDLockers
//
//  Created by Paul Oprea on 14/09/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class LockerTableViewCell: UITableViewCell {

    @IBOutlet weak var lockerNumberLabel: UILabel!
    @IBOutlet weak var lockerSizeLabel: UILabel!
    @IBOutlet weak var lockerAddressLabel: UILabel!
    @IBOutlet weak var lockedImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
