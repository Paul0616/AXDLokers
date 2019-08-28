//
//  ScanLabelViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 22/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainMenuViewController: UIViewController, RestRequestsDelegate {
   
    

    @IBOutlet weak var addParcelButton: UIButton!
    @IBOutlet weak var addLockerButton: UIButton!
    let restRequests = RestRequests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        alignTextBelow(button: addParcelButton)
        alignTextBelow(button: addLockerButton)
        addLockerButton.isEnabled = false
        addParcelButton.isEnabled = false
        addLockerButton.layer.cornerRadius = 10
        addParcelButton.layer.cornerRadius = 10
        restRequests.delegate = self
        
        if let userId = UserDefaults.standard.object(forKey: "userId") as? Int {
            let param = [KEY_userId: userId] as NSDictionary
            restRequests.checkForRequest(parameters: param, requestID: CHECK_USERS_REQUEST)
        } else {
           Switcher.updateRootVC(isLogged: false)
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
    @IBAction func tapLogOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Logging Out", message: "Do you really want to log out?", preferredStyle: UIAlertController.Style.alert)
        let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "isSuperAdmin")
            UserDefaults.standard.removeObject(forKey: "tokenExpiresAt")
            UserDefaults.standard.removeObject(forKey: "encryptedPassword")
            Switcher.updateRootVC(isLogged: false)
        })
        let canBut = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(okBut)
        alertController.addAction(canBut)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alignTextBelow(button: UIButton, spacing: CGFloat = 6.0) {
       button.imageView?.contentMode = .scaleAspectFit
        if let image = button.imageView?.image {
            let imageSize: CGSize = image.size
            button.titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width, bottom: -(imageSize.height), right: 0.0)
            let labelString = NSString(string: button.titleLabel!.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: button.titleLabel!.font!])
            button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        }
    }

    func userHaveRight(rights: JSON, code: String) -> Bool {
        for (_, right) in rights {
            if right[KEY_right][KEY_code].string == code {
                return true
            }
        }
        return false
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
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
