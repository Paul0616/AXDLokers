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
    
    var fullName: String!
    var phone: String!
    var email: String!
    var uniqueNumber: String!
    var buildingName: String!
    var address: String!
    var residentId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = fullName {
            fullNameLabel.text = fullName
        }
        if let _ = phone {
            phoneLabel.text = phone
        }
        if let _ = email {
            emailLabel.text = email
        }
        if let _ = uniqueNumber {
            uniqueNumberLabel.text = uniqueNumber
        }
        if let _ = buildingName {
            buildingNameLabel.text = buildingName
        }
        if let _ = address {
            addressLabel.text = address
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapOnConfirmButton(_ sender: Any) {
        //performSegue(withIdentifier: "confirmResident", sender: nil)
        print("CONFIRM resident id = \(residentId!)")
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
extension UIImageView {
    override open func awakeFromNib() {
        super.awakeFromNib()
        tintColorDidChange()
    }
}
