//
//  LogInViewController.swift
//  AXDLokers
//
//  Created by Paul Oprea on 19/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
//import SwiftDate

class LogInViewController: UIViewController, UITextFieldDelegate, RestRequestsDelegate{
   
    func resultedData(data: Data!, requestID: Int) {
        if requestID == RESET_PASSWORD_REQUEST {
            activityIndicator.stopAnimating()
            let alertController1 = UIAlertController(title: "Check your email", message: "A message about password recovery was sent to you.", preferredStyle: UIAlertController.Style.alert)
            let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
            alertController1.addAction(okBut)
            self.present(alertController1, animated: true, completion: nil)
            return
        }
        if requestID == CHECK_USERS_REQUEST {
            activityIndicator.stopAnimating()
            let json = try? JSON(data: data)
            UserDefaults.standard.set(json![KEY_firstName].string, forKey: "userFirstName")
            UserDefaults.standard.set(json![KEY_lastName].string, forKey: "userLastName")
            if let role: JSON = getJSON(json: json, desiredKey: KEY_role) {
                let hasRelatedBuilding: Bool = role[KEY_hasRelatedBuildings].int == 1 ? true : false
                if hasRelatedBuilding {
                    let buildingXUsers: JSON = getJSON(json: json, desiredKey: KEY_buildingXUsers)
                    if buildingXUsers.count == 0 {
                        let alertController = UIAlertController(title: "No building", message: "You've not been assigned any building. Please contact your administrator.", preferredStyle: UIAlertController.Style.alert)
                        let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                           print("No building. Stay in login screen")
                        })
                        alertController.addAction(saveAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        Switcher.updateRootVC(isLogged: true)
                    }
                } else {
                    Switcher.updateRootVC(isLogged: true)
                }
                
            }
        }
        
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        activityIndicator.stopAnimating()
        if errorCode == 404 {
            print("User does not exist or User email/password is not correct")
            let alertController = UIAlertController(title: "Login error",
                                                    message: "User does not exist or User email/password is not correct",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        if errorMessage.contains("The Internet connection appears to be offline."){
            let alertController = UIAlertController(title: "Internet connection",
                                                    message: "The Internet connection appears to be offline.",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var tapHereButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var userEmailText: String?
    let restRequests = RestRequests()
    override func viewDidLoad() {
        super.viewDidLoad()
//        let date1970 = Date(timeIntervalSince1970: 0)
//        var lastSyncDate = date1970.string(format: DateFormat.iso8601Auto)
//        lastSyncDate = lastSyncDate.replacingOccurrences(of: "Z", with: "")
//               print(lastSyncDate)
        userEmailTextField.delegate = self
        passwordTextField.delegate = self
        self.logo.alpha = 0
        restRequests.delegate = self
        if let userEmail = UserDefaults.standard.object(forKey: "userEmail") as? String {
            userEmailText = userEmail
        }
        // Do any additional setup after loading the view.
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: [.curveEaseOut], animations: {
            self.logo.transform = CGAffineTransform(translationX: 0, y: -180)
            self.logo.alpha = 1
        }, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
        self.userEmailTextField.text = userEmailText
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    @IBAction func tapLogin(_ sender: UIButton) {
        if userEmailTextField.text != nil && passwordTextField.text != nil {
            let encryptedPassword = encryptPassword(password: passwordTextField.text!)
            UserDefaults.standard.set(userEmailTextField.text!, forKey: "userEmail")
            UserDefaults.standard.set(encryptedPassword, forKey: "encryptedPassword")
            activityIndicator.startAnimating()
            restRequests.checkForRequest(parameters: nil, requestID: CHECK_USERS_REQUEST)
        }
    }
    //MARK: - UItextfieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        if textField == userEmailTextField{
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            //attemptLogin()
        }
        return true
    }
    @IBAction func onPasswordReset(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset pasword", message: "Enter your email address to recover your password", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your email address"
            textField.text = self.userEmailTextField.text
        }
        let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
//            print(firstTextField.text!)
            let body = [KEY_email: firstTextField.text!] as NSDictionary
            self.restRequests.checkForRequest(parameters: nil, requestID: RESET_PASSWORD_REQUEST, body: body)
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
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

