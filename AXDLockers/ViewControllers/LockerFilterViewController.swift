//
//  LockerFilterViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 13/09/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class LockerFilterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var lockerNumberTextField: UITextField!
    @IBOutlet weak var lockerStreetTextField: UITextField!
    @IBOutlet weak var lockerZipTextField: UITextField!
    
    var resident: BuildingXResident!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lockerNumberTextField.delegate = self
        lockerStreetTextField.delegate = self
        lockerZipTextField.delegate = self
        searchBarButtonItem.isEnabled = validation()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func validation() -> Bool {
        if lockerNumberTextField.text != "" || lockerStreetTextField.text != "" || lockerZipTextField.text != "" {
            return true
        } else {
            return false
        }
    }

    //MARK: - UItextfieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == lockerNumberTextField {
            lockerStreetTextField.becomeFirstResponder()
        }
        if textField == lockerStreetTextField {
            lockerZipTextField.becomeFirstResponder()
        }
        if textField == lockerZipTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        
        if textField == lockerZipTextField {
            animateViewMoving(up: true, moveValue: 100)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if textField == lockerZipTextField {
            animateViewMoving(up: false, moveValue: 100)
        }
    }
    
    @IBAction func lockerNumberEditing(_ sender: Any) {
        searchBarButtonItem.isEnabled = validation()
    }
    
    @IBAction func lockerStreetEditing(_ sender: Any) {
        searchBarButtonItem.isEnabled = validation()
    }
    @IBAction func lockerZipEditing(_ sender: Any) {
        searchBarButtonItem.isEnabled = validation()
    }
        //searchBarButtonItem.isEnabled = validation()
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "lockersList", let destination = segue.destination as? LockersListViewController{
            if !lockerNumberTextField.text!.isEmpty {
                destination.lockerNumber = lockerNumberTextField.text
            }
            if !lockerStreetTextField.text!.isEmpty {
                destination.lockerStreet = lockerStreetTextField.text
            }
            if !lockerZipTextField.text!.isEmpty {
                destination.lockerZip = lockerZipTextField.text
            }
            destination.resident = resident
        }
    }
    

}
