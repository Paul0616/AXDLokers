//
//  ScanLabelViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 22/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class MainMenuViewController: UIViewController, RestRequestsDelegate {
   
    

    @IBOutlet weak var addParcelButton: UIButton!
    @IBOutlet weak var addLockerButton: UIButton!
    let restRequests = RestRequests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
//       lastSyncDate = Defaults[.lastSyncDateUser] ?? date1970.string(format: DateFormat.iso8601Auto)
//       lastSyncDate = lastSyncDate.replacingOccurrences(of: "Z", with: "")
        
        // Do any additional setup after loading the view.
        alignTextBelow(button: addParcelButton)
        alignTextBelow(button: addLockerButton)
        addLockerButton.isEnabled = false
        addParcelButton.isEnabled = false
        addLockerButton.layer.cornerRadius = 10
        addParcelButton.layer.cornerRadius = 10
        restRequests.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.object(forKey: "userId") as? Int {
            restRequests.checkForRequest(parameters: nil, requestID: CHECK_USERS_REQUEST)
        } else {
            Switcher.updateRootVC(isLogged: false)
        }
//        UserDefaults.standard.set(false, forKey: "codeWasdetected")
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            print(key)
//        }
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addLockerFromMain", let destination = segue.destination as? QRScannerViewController {
            destination.addLockerOnly = true
        }
    }
   
    @IBAction func tapLogOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Logging Out", message: "Do you really want to log out?", preferredStyle: UIAlertController.Style.alert)
        let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "isSuperAdmin")
            UserDefaults.standard.removeObject(forKey: "tokenExpiresAt")
            UserDefaults.standard.removeObject(forKey: "encryptedPassword")
            
            UserDefaults.standard.removeObject(forKey: "lastInsertedParcelId")
            UserDefaults.standard.removeObject(forKey: "lastInsertedLockerHistoriesId")
            UserDefaults.standard.removeObject(forKey: "lastInsertedVirtualParcelId")
            Switcher.updateRootVC(isLogged: false)
        })
        let canBut = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(okBut)
        alertController.addAction(canBut)
        self.present(alertController, animated: true, completion: nil)
    }
 

    
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        if let _ = errorCode {
            self.showToast(message: "Error code: \(errorCode!) - \(errorMessage)")
        }
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        if requestID == CHECK_USERS_REQUEST {
            let userXRights: JSON = getJSON(json: json, desiredKey: KEY_userRights)
            addParcelButton.isEnabled = (userHaveRight(rights: userXRights, code: "READ_RESIDENT") && userHaveRight(rights: userXRights, code: "READ_BUILDING"))
            addLockerButton.isEnabled = userHaveRight(rights: userXRights, code: "CREATE_LOCKER")
        }
    }
}
