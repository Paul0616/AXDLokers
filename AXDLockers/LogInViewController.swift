//
//  LogInViewController.swift
//  AXDLokers
//
//  Created by Paul Oprea on 19/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate, RestRequestsDelegate{
   
    func resultedData(data: Data!, requestID: Int) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            print(json)
            let items = json["items"] as! NSArray
            let item = items[0] as! NSDictionary
            UserDefaults.standard.set(item["accessToken"] as! String, forKey: "token")
            UserDefaults.standard.set(item["id"] as! Int, forKey: "userId")
            let isAdmin = item["isSuperAdmin"] as! Int
            UserDefaults.standard.set(isAdmin == 1 ? true : false, forKey: "isSuperAdmin")
            UserDefaults.standard.set(item["tokenExpiresAt"] as! Double, forKey: "tokenExpiresAt")
            Switcher.updateRootVC(isLogged: true)
        } catch let error as NSError
        {
            print(error)
        }
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
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
    var userEmailText: String?
    let restRequests = RestRequests()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            restRequests.checkForRequest(parameters: nil, requestID: TOKEN_REQUEST)
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

