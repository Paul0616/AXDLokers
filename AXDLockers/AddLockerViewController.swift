//
//  AddLockerViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 25/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class AddLockerViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lockerImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lockerNumberTextField: UITextField!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addaddressButton: UIButton!
    
    @IBOutlet weak var lockerSizeTextField: UITextField!
    
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lockerImage.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        lockerNumberTextField.delegate = self
        lockerSizeTextField.delegate = self
        self.scrollView.isScrollEnabled = false
        addaddressButton.layer.cornerRadius = 6
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField
        {
            if (!aRect.contains(activeFieldPresent.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeFieldPresent.frame, animated: true)
            }
        }
        
        
    }
    
    
    @objc func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
    }
    @IBAction func addAddressAction(_ sender: UIButton) {
        
    }
    
    //MARK: - UItextfieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        if textField == lockerNumberTextField {
            lockerSizeTextField.becomeFirstResponder()
        }
        
        if textField == lockerSizeTextField {
            textField.resignFirstResponder()
            //attemptLogin()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        activeField = nil
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
