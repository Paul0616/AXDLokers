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
        title = "Finding Resident"
        fullNameTextField.delegate = self
        unitTextField.delegate = self
        if let line1 = line1 {
            fullNameTextField.text = line1
        }
        if let line2 = line2 {
            unitTextField.text = line2
        }
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        setSearchButtonStatus()
    }
    

    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func tapScan(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SCANLabel") as! ScanLabelViewController
        
        navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func setSearchButtonStatus(){
        searchResidentsButton.isEnabled = (fullNameTextField.text?.trimmingCharacters(in: .whitespaces) != "" || unitTextField.text?.trimmingCharacters(in: .whitespaces) != "")
    }
    
    @IBAction func topSearchResidents(_ sender: Any) {
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "selectResident", let tableVC = segue.destination as? ResidentsFilteredViewController  {
            if fullNameTextField.text != "" {
                tableVC.fullName = fullNameTextField.text?.trimmingCharacters(in: .whitespaces)
            }
            if unitTextField.text != "" {
                tableVC.unitNumber = unitTextField.text?.trimmingCharacters(in: .whitespaces)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setSearchButtonStatus()
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
