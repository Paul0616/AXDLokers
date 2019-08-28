//
//  SecurityCodeViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 29/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
//import SwiftyJSON

class SecurityCodeViewController: UIViewController{
    
    
    var lockerId: Int!
    var lockerHistory: LockerHistory!
    var resident: Resident!
    
    
    
    @IBOutlet weak var lockerView: UIView!
    @IBOutlet weak var residentView: UIView!
    @IBOutlet weak var lockerNumberLabel: UILabel!
    @IBOutlet weak var lockerAddressLabel: UILabel!
    @IBOutlet weak var lockerSizeLabel: UILabel!
    @IBOutlet weak var residentNameLabel: UILabel!
    @IBOutlet weak var residentSuiteNumberLabel: UILabel!
    @IBOutlet weak var residentPhoneLabel: UILabel!
    @IBOutlet weak var residentEmailLabel: UILabel!
    @IBOutlet weak var securityCodeLabel: UILabel!
    
    @IBOutlet weak var imageLocker: UIImageView!
    @IBOutlet weak var imageResident: UIImageView!
    @IBOutlet weak var confirmButton: UIButton!
    var alertController: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lockerView.layer.borderWidth = 1
        lockerView.layer.cornerRadius = 10
        lockerView.layer.borderColor = UIColor.darkGray.cgColor
        residentView.layer.borderWidth = 1
        residentView.layer.cornerRadius = 10
        residentView.layer.borderColor = UIColor.darkGray.cgColor
        imageLocker.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        imageResident.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        
        if resident != nil {
            residentNameLabel.text = resident.firstName + " " + resident.lastName
            residentSuiteNumberLabel.text = resident.suiteNumber
            residentPhoneLabel.text = resident.phone
            residentEmailLabel.text = resident.email
            securityCodeLabel.text = resident.securityCode
        }
        if lockerHistory != nil {
            lockerNumberLabel.text = "#"+lockerHistory.number
            lockerSizeLabel.text = lockerHistory.size
            lockerAddressLabel.text = lockerHistory.lockerAddress
        }
        // Do any additional setup after loading the view.
//        if locker != nil {
//            let param = [
//                "expand": KEY_address + "." + KEY_city + "." + KEY_state,
//                KEY_id: locker.id
//                ] as [String: Any?]
//            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: LOCKERS_REQUEST)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.removeObject(forKey: "codeWasdetected")
    }
   
    @IBAction func onConfirmAction(_ sender: Any) {
        
    }
    
//    private func showAlert()->UIAlertController{
//        let alertController = UIAlertController(title: "Please wait",
//                                                message: "Please wait until you get confirmation that notification was sent to resident...",
//                                                preferredStyle: .alert)
//
//        self.present(alertController, animated: true, completion: nil)
//        return alertController
//    }
   
   //  MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finalConfirmationSegue" {
            let dest = segue.destination as! FinalConfirmationViewController
            dest.lockerId = lockerId
            dest.lockerHistory = lockerHistory
            dest.resident = resident
        }
    }
  

}
