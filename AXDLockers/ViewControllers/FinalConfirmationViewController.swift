//
//  FinalConfirmationViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 31/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

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
            1. If I found something in UserDefaults Delete lastInsertedParcelId and lastInsertedLockerHistoriesId
            2. Insert parcel, then get lastInsertedParcelId and save it in UserDefaults.
            3. Insert record in locker-histories and save lastInsertedLockerHistoriesId it in UserDefaults.
            4. Once I know lockerBuildingResidentId, wich will be equal with lastInsertedParcelId I'm inserting notification and if it was successful going to scan screen, else do nothing and user can go back to security code screen and try again
         ##############################*/
       
        if lockerId != 0 {
            UserDefaults.standard.removeObject(forKey: "lastInsertedVirtualParcelId")
            if let lastInsertedParcelId = UserDefaults.standard.object(forKey: "lastInsertedParcelId") as? Int {
                deleteParcel(lastInsertedParcelId, isVirtual: false)
            } else if let lastInsertedLockerHistoriesId = UserDefaults.standard.object(forKey: "lastInsertedLockerHistoriesId") as? Int {
                deleteHistory(lastInsertedLockerHistoriesId)
            } else {
                insertParcel(isVirtual: false)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: "lastInsertedParcelId")
            if let lastInsertedVirtualParcelId = UserDefaults.standard.object(forKey: "lastInsertedVirtualParcelId") as? Int {
                deleteParcel(lastInsertedVirtualParcelId, isVirtual: true)
            } else if let lastInsertedLockerHistoriesId = UserDefaults.standard.object(forKey: "lastInsertedLockerHistoriesId") as? Int {
                deleteHistory(lastInsertedLockerHistoriesId)
            } else {
                insertParcel(isVirtual: true)
            }
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
        if let _ = errorCode {
            self.showToast(message: "Error code: \(errorCode!) - \(errorMessage)")
        }
        cancelButton.isEnabled = true
        infoLabel.text = ""
      //  if errorCode == 422 {
            activityIndicator.stopAnimating()
            popUpView.backgroundColor = UIColor.red
            label.textColor = UIColor.white
            label.text = "Sending notification to resident failed."
      //  }
    }
    
    fileprivate func handleSuccessAction(_ json: JSON?) {
       if (json?[KEY_id].int!) != nil {
            activityIndicator.stopAnimating()
            popUpView.backgroundColor = UIColor.green
            backToScanButton.isHidden = false
            label.text = "A notification about package was sent to resident."
            infoLabel.text = ""
            UserDefaults.standard.removeObject(forKey: "lastInsertedParcelId")
            UserDefaults.standard.removeObject(forKey: "lastInsertedLockerHistoriesId")
            UserDefaults.standard.removeObject(forKey: "lastInsertedVirtualParcelId")
        }
    }
    
    fileprivate func deleteParcel(_ lastInsertedParcelId: Int, isVirtual: Bool) {
        infoLabel.text = "Deleting last failed parcel..."
        if !isVirtual {
            let parameter:Parameters = [KEY_id: lastInsertedParcelId] as Parameters
            self.restRequest.checkForRequest(parameters: parameter, requestID: DELETE_LOCKER_BUILDING_RESIDENT_REQUEST)
        } else {
            //TODO: - 1. delete virtual parcel not implemented(405 method not allowed). need method on API
            let parameter:Parameters = [KEY_id: lastInsertedParcelId] as Parameters
            self.restRequest.checkForRequest(parameters: parameter, requestID: DELETE_VIRTUAL_PARCEL_REQUEST)
        }
    }

    fileprivate func deleteHistory(_ lastInsertedLockerHistoriesId: Int) {
        infoLabel.text = "Deleting last failed locker history..."
        let parameter = [KEY_id: lastInsertedLockerHistoriesId] as Parameters
        self.restRequest.checkForRequest(parameters: parameter, requestID: DELETE_LOCKER_HISTORIES_REQUEST)
    }
    
    fileprivate func insertLockerHistory() {
        infoLabel.text = "Creating locker history..."
        let body = createHistoryParameter()
        restRequest.checkForRequest(parameters: nil, requestID: INSERT_LOCKER_HISTORIES_REQUEST, body: body)
    }
    
    fileprivate func insertParcel(isVirtual: Bool) {
        if !isVirtual {
            infoLabel.text = "Creating locker - bulding - resident association..."
            let body = [
                KEY_lockerId: self.lockerId!,
                KEY_buildingResidentId: self.resident.buildingResidentId,
                KEY_securityCode: self.lockerHistory.securityCode!,
                KEY_status: STATUS_NOT_CONFIRMED
                ] as [String : Any]
            self.restRequest.checkForRequest(parameters: nil, requestID: INSERT_LOCKER_BUILDING_RESIDENT_REQUEST, body: body as NSDictionary)
        } else {
            infoLabel.text = "Creating association with temporary locker..."
            let body = [
                KEY_buildingResidentId: self.resident.buildingResidentId,
                "lockerNumber": self.lockerHistory.locker.number,
                "lockerSize": self.lockerHistory.locker.size,
                KEY_addressId: self.lockerHistory.locker.address.id,
                "addressDetails": self.lockerHistory.locker.addressDetail!,
                KEY_securityCode: self.lockerHistory.securityCode!,
                KEY_status: STATUS_NOT_CONFIRMED
                ] as [String : Any]
            
            self.restRequest.checkForRequest(parameters: nil, requestID: INSERT_VIRTUAL_PARCEL_REQUEST, body: body as NSDictionary)
        }
    }
    
    fileprivate func insertNotification(isVirtual: Bool) {
        infoLabel.text = "Sending notification to resident..."
        if !isVirtual{
            let body = [
                KEY_lockerBuildingResidentId: UserDefaults.standard.object(forKey: "lastInsertedParcelId") as! Int
                ] as [String : Any]
            restRequest.checkForRequest(parameters: nil, requestID: INSERT_NOTIFICATION_REQUEST, body: body as NSDictionary)
        } else {
            let body = [
                KEY_virtualParcelId: UserDefaults.standard.object(forKey: "lastInsertedVirtualParcelId") as! Int
                ] as [String : Any]
            restRequest.checkForRequest(parameters: nil, requestID: INSERT_NOTIFICATION_FOR_VIRTUAL_PARCEL_REQUEST, body: body as NSDictionary)
        }
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
//        print(requestID)
        
        if requestID == DELETE_LOCKER_BUILDING_RESIDENT_REQUEST {
           UserDefaults.standard.removeObject(forKey: "lastInsertedParcelId")
            if let lastInsertedLockerHistoriesId = UserDefaults.standard.object(forKey: "lastInsertedLockerHistoriesId") as? Int {
                deleteHistory(lastInsertedLockerHistoriesId)
            } else {
                insertParcel(isVirtual: false)
            }
        }
        
        if requestID == DELETE_LOCKER_HISTORIES_REQUEST {
           UserDefaults.standard.removeObject(forKey: "lastInsertedLockerHistoriesId")
            if lockerId != 0 {
                insertParcel(isVirtual: false)
            } else {
                insertParcel(isVirtual: true)
            }
        }
        
        if requestID == DELETE_VIRTUAL_PARCEL_REQUEST {
            UserDefaults.standard.removeObject(forKey: "lastInsertedVirtualParcelId")
            if let lastInsertedLockerHistoriesId = UserDefaults.standard.object(forKey: "lastInsertedLockerHistoriesId") as? Int {
                deleteHistory(lastInsertedLockerHistoriesId)
            } else {
                insertParcel(isVirtual: true)
            }
        }
        
        if requestID == INSERT_NOTIFICATION_REQUEST {
            handleSuccessAction(json)
        }
        
        if requestID == INSERT_NOTIFICATION_FOR_VIRTUAL_PARCEL_REQUEST {
            //TODO: - 2. this method return NIL in body and need to return created entity
            //handleSuccessAction(json)
            //Following will be deleted after 2. will be resolved
            activityIndicator.stopAnimating()
            popUpView.backgroundColor = UIColor.green
            backToScanButton.isHidden = false
            label.text = "A notification about package was sent to resident."
            infoLabel.text = ""
            UserDefaults.standard.removeObject(forKey: "lastInsertedParcelId")
            UserDefaults.standard.removeObject(forKey: "lastInsertedLockerHistoriesId")
            UserDefaults.standard.removeObject(forKey: "lastInsertedVirtualParcelId")
        }
       
        if requestID == INSERT_LOCKER_BUILDING_RESIDENT_REQUEST {
            if let lastInsertedParcelId = json?[KEY_id].int! {
                UserDefaults.standard.set(lastInsertedParcelId, forKey: "lastInsertedParcelId")
                insertLockerHistory()
            }
        }
        
        if requestID == INSERT_LOCKER_HISTORIES_REQUEST {
            if let lastInsertedLockerHistoriesId = json?[KEY_id].int! {
                UserDefaults.standard.set(lastInsertedLockerHistoriesId, forKey: "lastInsertedLockerHistoriesId")
                if lockerId != 0 {
                    insertNotification(isVirtual: false)
                } else {
                    //#########??????????????????
                    insertNotification(isVirtual: true)
                    //##########?????????????????
                }
            }
        }
        
        if requestID == INSERT_VIRTUAL_PARCEL_REQUEST {
            if let lastInsertedParcelId = json?[KEY_id].int! {
                UserDefaults.standard.set(lastInsertedParcelId, forKey: "lastInsertedVirtualParcelId")
                insertLockerHistory()
            }
        }
    }

    
    func createHistoryParameter() -> NSDictionary{
        let lockerAddressArray = [lockerHistory.locker.address.street, lockerHistory.locker.address.cityName, lockerHistory.locker.address.stateName, lockerHistory.locker.address.zipCode]
        var param = [
            KEY_qrCode: lockerHistory.locker.qrCode,
            KEY_number: lockerHistory.locker.number,
            KEY_size: lockerHistory.locker.size,
            KEY_lockerAddress: lockerAddressArray.joined(separator: ", "),
            KEY_firstName: lockerHistory.resident.firstName,
            KEY_lastName: lockerHistory.resident.lastName,
            KEY_email: lockerHistory.resident.email,
            KEY_securityCode: lockerHistory.securityCode!,
            KEY_suiteNumber: lockerHistory.resident.suiteNumber,
            KEY_buildingUniqueNumber: lockerHistory.resident.building!.buidingUniqueNumber,
            KEY_name: lockerHistory.resident.building!.name,
            KEY_buildingAddress: [lockerHistory.resident.building!.street, lockerHistory.resident.building!.address].joined(separator: " "),
            "residentAddress": [lockerHistory.resident.building!.street, lockerHistory.resident.building!.address].joined(separator: " "),
            "createdByEmail": UserDefaults.standard.object(forKey: "userEmail") as! String,
            "packageStatus": "STATUS_NOT_CONFIRMED",
            "createdByFirstName": UserDefaults.standard.object(forKey: "userFirstName") as! String,
            "createdByLastName": UserDefaults.standard.object(forKey: "userLastName") as! String] as [String : Any]
        if lockerHistory.resident.phone != "-" {
            param[KEY_phone] = lockerHistory.resident.phone
        }
        if lockerHistory.locker.size != "-" {
            param[KEY_size] = lockerHistory.locker.size
        }
        return param as NSDictionary
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
