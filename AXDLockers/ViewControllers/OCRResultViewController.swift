//
//  OCRResultViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 22/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class OCRResultViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var searchResidentsButton: UIButton!
    var line1: String!
    var line2: String!
    var line3: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullNameTextField.delegate = self
        unitTextField.delegate = self
        if let line1 = line1 {
            fullNameTextField.text = line1
        }
        if let line2 = line2 {
            unitTextField.text = line2
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    

    @IBAction func tapScan(_ sender: Any) {
    }
    @IBAction func topSearchResidents(_ sender: Any) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectResident" {
            let navVC = segue.destination as? UINavigationController
            let tableVC = navVC?.viewControllers.first as! ResidentsFilteredViewController
            if fullNameTextField.text != "" {
                tableVC.fullName = fullNameTextField.text
            }
            if unitTextField.text != "" {
                tableVC.unitNumber = unitTextField.text
            }
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameTextField {
            textField.resignFirstResponder()
            unitTextField.becomeFirstResponder()
        }
        if textField == unitTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
//    @IBAction func unwindResult(sender: UIStoryboardSegue) {
//        
//        if let sourceViewController = sender.source as? ChooseBuildingViewController {
//            currentBuildingId = sourceViewController.selectedBuildingId
//            refreshButton()
//            refreshBuilding()
//        }
//    }
}
