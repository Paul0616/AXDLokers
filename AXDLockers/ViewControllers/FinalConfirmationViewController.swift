//
//  FinalConfirmationViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 31/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class FinalConfirmationViewController: UIViewController, RestRequestsDelegate {
    var lockerId: Int!
    var lockerHistory: LockerHistory!
    var resident: Resident!
    

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backToScanButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let restRequest = RestRequests()
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 6
        backToScanButton.isHidden = true
        cancelButton.isEnabled = false
        restRequest.delegate = self
        // Do any additional setup after loading the view.
        activityIndicator.startAnimating()
        /* ##############################
            1. If I found something in UserDefaults Delete lastInsertedLockerBuildingResidentId and lastInsertedLockerHistoriesId
            2. First check locker-bulding-residents if pair lockerId / buildingResidentId was used before
            3. If YES just get lastInsertedLockerBuildingResidentId and save it in UserDefaults. If NO insert it, then get lastInsertedLockerBuildingResidentId and save it in UserDefaults.
            4. Insert record in locker-histories and save lastInsertedLockerHistoriesId it in UserDefaults.
            5. Once I know lockerBuildibgResidentId = lastInsertedLockerBuildingResidentId I'm inserting notification and if it was successful going to scan screen, else do nothing and user can go back to security code screen and try again
         ##############################*/
        infoLabel.text = "Checking locker - bulding - resident association..."
        
        if let lastInsertedLockerBuildingResidentId = UserDefaults.standard.object(forKey: "lastInsertedLockerBuildingResidentId") as? Int {
            let parameter = [KEY_id: lastInsertedLockerBuildingResidentId]
            self.restRequest.checkForRequest(parameters: parameter as NSDictionary, requestID: DELETE_LOCKER_BUILDING_RESIDENT_REQUEST)
        } else if let lastInsertedLockerHistoriesId = UserDefaults.standard.object(forKey: "lastInsertedLockerHistoriesId") as? Int {
            let parameter = [KEY_id: lastInsertedLockerHistoriesId]
            self.restRequest.checkForRequest(parameters: parameter as NSDictionary, requestID: DELETE_LOCKER_HISTORIES_REQUEST)
        } else {
            let param = [
                KEY_lockerId: self.lockerId!,
                KEY_buildingResidentId: self.resident.buildingResidentId
                ] as [String : Any]
            self.restRequest.checkForRequest(parameters: param as NSDictionary, requestID: LOCKER_BUILDING_RESIDENT_REQUEST)
        }
        
    }
    
    @IBAction func onClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func backToScanAction(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!) - \(errorMessage)")
        cancelButton.isEnabled = true
        infoLabel.text = ""
      //  if errorCode == 422 {
            activityIndicator.stopAnimating()
            popUpView.backgroundColor = UIColor.red
            label.textColor = UIColor.white
            label.text = "Sending notification to resident failed."
      //  }
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        print(requestID)
        if requestID == DELETE_LOCKER_BUILDING_RESIDENT_REQUEST {
           UserDefaults.standard.removeObject(forKey: "lastInsertedLockerBuildingResidentId")
            if let lastInsertedLockerHistoriesId = UserDefaults.standard.object(forKey: "lastInsertedLockerHistoriesId") as? Int {
                let parameter = [KEY_id: lastInsertedLockerHistoriesId]
                self.restRequest.checkForRequest(parameters: parameter as NSDictionary, requestID: DELETE_LOCKER_HISTORIES_REQUEST)
            } else {
                let param = [
                    KEY_lockerId: self.lockerId!,
                    KEY_buildingResidentId: self.resident.buildingResidentId
                    ] as [String : Any]
                self.restRequest.checkForRequest(parameters: param as NSDictionary, requestID: LOCKER_BUILDING_RESIDENT_REQUEST)
            }
        }
        if requestID == DELETE_LOCKER_HISTORIES_REQUEST {
           UserDefaults.standard.removeObject(forKey: "lastInsertedLockerHistoriesId")
            let param = [
                        KEY_lockerId: self.lockerId!,
                        KEY_buildingResidentId: self.resident.buildingResidentId
                        ] as [String : Any]
            self.restRequest.checkForRequest(parameters: param as NSDictionary, requestID: LOCKER_BUILDING_RESIDENT_REQUEST)
        }
        if requestID == LOCKER_BUILDING_RESIDENT_REQUEST {
            if let items: JSON = getJSON(json: json, desiredKey: KEY_items), items.count > 0 {
                for (_, value) in items {
                    if let lastInsertedLockerBuildingResidentId = value[KEY_id].int {
                        UserDefaults.standard.set(lastInsertedLockerBuildingResidentId, forKey: "lastInsertedLockerBuildingResidentId")
                    }
                    break
                }
                infoLabel.text = "Creating locker history..."
                var param = [
                    KEY_qrCode: lockerHistory.qrCode,
                    KEY_number: lockerHistory.number,
                    KEY_size: lockerHistory.size,
                    KEY_lockerAddress: lockerHistory.lockerAddress,
                    KEY_firstName: lockerHistory.firstName,
                    KEY_lastName: lockerHistory.lastName,
                    KEY_email: lockerHistory.email,
                    KEY_securityCode: lockerHistory.securityCode,
                    KEY_suiteNumber: lockerHistory.suiteNumber,
                    KEY_buildingUniqueNumber: lockerHistory.buildingUniqueNumber,
                    KEY_name: lockerHistory.name,
                    KEY_buildingAddress: lockerHistory.buildingAddress,
                    "residentAddress": lockerHistory.residentAddress,
                    "createdByEmail": UserDefaults.standard.object(forKey: "userEmail") as! String,
                    "packageStatus": "STATUS_NOT_CONFIRMED",
                    "createdByFirstName": UserDefaults.standard.object(forKey: "userFirstName") as! String,
                    "createdByLastName": UserDefaults.standard.object(forKey: "userLastName") as! String] as [String : Any]
                if lockerHistory.phoneNumber != "-" {
                    param[KEY_phone] = lockerHistory.phoneNumber
                }
                if lockerHistory.size != "-" {
                    param[KEY_size] = lockerHistory.size
                }
                restRequest.checkForRequest(parameters: param as NSDictionary, requestID: INSERT_LOCKER_HISTORIES_REQUEST)
            } else {
                infoLabel.text = "Creating locker - bulding - resident association..."
                let param = [
                    KEY_lockerId: self.lockerId!,
                    KEY_buildingResidentId: self.resident.buildingResidentId,
                    KEY_status: STATUS_NOT_CONFIRMED
                    ] as [String : Any]
                self.restRequest.checkForRequest(parameters: param as NSDictionary, requestID: INSERT_LOCKER_BUILDING_RESIDENT_REQUEST)
            }
        }
        if requestID == INSERT_NOTIFICATION_REQUEST {
            if (json?[KEY_id].int!) != nil {
                activityIndicator.stopAnimating()
                popUpView.backgroundColor = UIColor.green
                backToScanButton.isHidden = false
                label.text = "A notification about package was sent to resident."
                infoLabel.text = ""
                UserDefaults.standard.removeObject(forKey: "lastInsertedLockerBuildingResidentId")
                UserDefaults.standard.removeObject(forKey: "lastInsertedLockerHistoriesId")
            }
        }
       
        if requestID == INSERT_LOCKER_BUILDING_RESIDENT_REQUEST {
            if let lastInsertedLockerBuildingResidentId = json?[KEY_id].int! {
                UserDefaults.standard.set(lastInsertedLockerBuildingResidentId, forKey: "lastInsertedLockerBuildingResidentId")
                infoLabel.text = "Creating locker history..."
                var param = [
                    KEY_qrCode: lockerHistory.qrCode,
                    KEY_number: lockerHistory.number,
                    KEY_size: lockerHistory.size,
                    KEY_lockerAddress: lockerHistory.lockerAddress,
                    KEY_firstName: lockerHistory.firstName,
                    KEY_lastName: lockerHistory.lastName,
                    KEY_email: lockerHistory.email,
                    KEY_securityCode: lockerHistory.securityCode,
                    KEY_suiteNumber: lockerHistory.suiteNumber,
                    KEY_buildingUniqueNumber: lockerHistory.buildingUniqueNumber,
                    KEY_name: lockerHistory.name,
                    KEY_buildingAddress: lockerHistory.buildingAddress,
                    "residentAddress": lockerHistory.residentAddress,
                    "createdByEmail": UserDefaults.standard.object(forKey: "userEmail") as! String,
                    "packageStatus": "STATUS_NOT_CONFIRMED",
                    "createdByFirstName": UserDefaults.standard.object(forKey: "userFirstName") as! String,
                    "createdByLastName": UserDefaults.standard.object(forKey: "userLastName") as! String] as [String : Any]
                if lockerHistory.phoneNumber != "-" {
                    param[KEY_phone] = lockerHistory.phoneNumber
                }
                if lockerHistory.size != "-" {
                    param[KEY_size] = lockerHistory.size
                }
                restRequest.checkForRequest(parameters: param as NSDictionary, requestID: INSERT_LOCKER_HISTORIES_REQUEST)
            }
        }
        if requestID == INSERT_LOCKER_HISTORIES_REQUEST {
            if let lastInsertedLockerHistoriesId = json?[KEY_id].int! {
                
                UserDefaults.standard.set(lastInsertedLockerHistoriesId, forKey: "lastInsertedLockerHistoriesId")
                 infoLabel.text = "Sending notification to resident..."
                let param = [
                    KEY_lockerBuildingResidentId: UserDefaults.standard.object(forKey: "lastInsertedLockerBuildingResidentId") as! Int
                    ] as [String : Any]
                
                restRequest.checkForRequest(parameters: param as NSDictionary, requestID: INSERT_NOTIFICATION_REQUEST)
            }
        }
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
