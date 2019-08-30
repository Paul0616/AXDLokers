//
//  ConfirmResidentViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 23/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class ConfirmResidentViewController: UIViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var uniqueNumberLabel: UILabel!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
//    var fullName: String!
//    var phone: String!
//    var email: String!
//    var uniqueNumber: String!
//    var buildingName: String!
//    var address: String!
//    var residentId: Int!
    var resident: Resident!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let res = resident {
            var fullName: String = ""
            fullName += res.firstName + " \(res.lastName)"
            fullNameLabel.text = fullName
            phoneLabel.text = res.phone
            emailLabel.text = res.email
            if let building = res.building{
                uniqueNumberLabel.text = building.buidingUniqueNumber
                buildingNameLabel.text = building.name
                var addr = "\(resident.suiteNumber) - "
                if building.street != nil {
                    addr += "\(building.street!)\n"
                }
                addr += "\(building.address)"
                addressLabel.text = addr
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapOnConfirmButton(_ sender: Any) {
        //performSegue(withIdentifier: "confirmResident", sender: nil)
        print("CONFIRM resident id = \(resident!.id) building id = \(resident!.buildingResidentId)")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        //let nc = segue.destination as? UINavigationController
        if segue.identifier == "scanQRCode", let destination = segue.destination as? QRScannerViewController {
            destination.resident = resident
            destination.addLockerOnly = false
        }
    }
    

}
extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}
