//
//  LogInViewController.swift
//  AXDLokers
//
//  Created by Paul Oprea on 19/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var tapHereButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    var usernameText: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        self.logo.alpha = 0
        // Do any additional setup after loading the view.
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: [.curveEaseOut], animations: {
            self.logo.transform = CGAffineTransform(translationX: 0, y: -180)
            self.logo.alpha = 1
        }, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.passwordTextField.text = nil
        self.userNameTextField.text = usernameText
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    @IBAction func tapLogin(_ sender: UIButton) {
        if userNameTextField.text != nil {
            UserDefaults.standard.set(1, forKey: "userId")
            Switcher.updateRootVC()
        }
    }
    //MARK: - UItextfieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        if textField == userNameTextField{
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
