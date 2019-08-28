//
//  ResidentsFilteredViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 22/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class ResidentsFilteredViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RestRequestsDelegate {
    
    
    
    @IBOutlet weak var nextButtonBar: UIBarButtonItem!
    var fullName: String!
    var unitNumber: String!
    var line3Address: String!
    var line4Street: String!
    let restRequest = RestRequests()
    
    
    @IBOutlet weak var orphansButton: UIButton!
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
    //    var isFiltered: Bool = false
    var loadedPages: Int = 0
    var residents: [Resident] = [Resident]()
    var currentResidentIndex: Int!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        restRequest.delegate = self
        
        isLoading = true
        title = "Select Resident"
        nextButtonBar.isEnabled = false
        orphansButton.titleLabel?.textAlignment = .center
       //orphansButton.visiblity(gone: true)
        orphansButton.isEnabled = false
        if let _ = fullName {
            orphansButton.isEnabled = true
        }
        if let _ = unitNumber {
            orphansButton.isEnabled = true
        }
        
        
        getFilteredResidents()
        // Do any additional setup after loading the view.
    }
    

    @IBAction func tapOnNextButton(_ sender: Any) {
        performSegue(withIdentifier: "confirmResident", sender: nil)

    }
    
    
    func getFilteredResidents(){
        
        var param:[String: Any]!
        if let fullName = fullName{
            param = [:]
            param["fullName"] = fullName
        }
        if let unitNumber = unitNumber{
            if param == nil {
                param = [:]
            }
            param["unitNumber"] = unitNumber
        }
        if let _ = param {
            activityIndicator.startAnimating()
            let param1 = ["per-page": PAGE_SIZE,
                          "expand": KEY_resident+","+KEY_building+"."+KEY_address+"."+KEY_city+"."+KEY_state+"."+KEY_country] as NSDictionary
        
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_BY_FULL_NAME_AND_UNIT_NUMBER, param1: param1)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellFilteredResident") as! ResidentAndBuildingTableViewCell
        cell.residentNameLabel.text = residents[indexPath.row].firstName + " " + residents[indexPath.row].lastName
        cell.unitNumberLabel.text = residents[indexPath.row].suiteNumber
        cell.buildingNameLabel.text = residents[indexPath.row].building!.name
        cell.addressLabel.text = residents[indexPath.row].building!.address
        cell.streetLabel.text = residents[indexPath.row].building!.street
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == residents.count-1 && !isLoading && !isLastPage {
            //we are at the last cell and need to load more
            loadedPages = loadedPages + 1
            let param1 = ["per-page": PAGE_SIZE, "page": loadedPages, "expand": KEY_resident+","+KEY_building+"."+KEY_address] as NSDictionary
            restRequest.checkForRequest(parameters: param1 as NSDictionary, requestID: GET_BY_FULL_NAME_AND_UNIT_NUMBER, param1: param1)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == currentResidentIndex  {
            tableView.deselectRow(at: indexPath, animated: true)
            currentResidentIndex = nil
            nextButtonBar.isEnabled = false
            orphansButton.isEnabled = true
        } else {
            currentResidentIndex = indexPath.row
            nextButtonBar.isEnabled = true
            orphansButton.isEnabled = false
        }
        
    }
   
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        activityIndicator.stopAnimating()
        print(errorMessage)
        isLoading = false
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        if requestID == GET_BY_FULL_NAME_AND_UNIT_NUMBER {
            isLoading = false
            activityIndicator.stopAnimating()
            let json = try? JSON(data: data)
            if let meta: JSON = getJSON(json: json, desiredKey: KEY_meta) {
                let currentPage = meta["currentPage"].int
                if loadedPages != currentPage {
                    loadedPages = currentPage!
                }
            }
            isLastPage = isLastPageLoaded(json: json)
            if let items: JSON = getJSON(json: json, desiredKey: KEY_items), items.count > 0 {
                for (_, value) in items {
                    guard let id = value[KEY_resident][KEY_id].int else { return  }
                    guard let buildingResidentId = value[KEY_buildingId].int else { return  }
                    let suiteNumber = value[KEY_suiteNumber].string!
                    let firstName = value[KEY_resident][KEY_firstName].string!
                    let lastName = value[KEY_resident][KEY_lastName].string!
                    var phone = "-"
                    if value[KEY_resident][KEY_phone].type != SwiftyJSON.Type.null {
                        phone = value[KEY_resident][KEY_phone].string!
                    }
                    let email = value[KEY_resident][KEY_email].string!
                    let securityCode = value[KEY_resident][KEY_securityCode].string!
                    
                    let resident = Resident(id: id, firstName: firstName, lastName: lastName, phone: phone, email: email, securityCode: securityCode, suiteNumber: suiteNumber, buildingResidentId: buildingResidentId)
                    let buildingid = value[KEY_building][KEY_id].int!
                    let buildingName = value[KEY_building][KEY_name].string!
                    let buildingUniqueNumber = value[KEY_building][KEY_buildingUniqueNumber].string!
                    let street = value[KEY_building][KEY_address][KEY_streetName].string!
                    var address = value[KEY_building][KEY_address][KEY_zipCode].string!
                    address += " " + value[KEY_building][KEY_address][KEY_city][KEY_name].string!
                    address += " " + value[KEY_building][KEY_address][KEY_city][KEY_state][KEY_name].string!
                    address += " " + value[KEY_building][KEY_address][KEY_city][KEY_state][KEY_country][KEY_name].string!
                    let building = Building(id: buildingid, name: buildingName, address: address, buidingUniqueNumber: buildingUniqueNumber)
                    building.street = street
                    resident.building = building
                    residents.append(resident)
                }
            }
           // print(residents.count > 0)
            //orphansButton.visiblity(gone: residents.count > 0, dimension: 70)
            //orphansButton.isEnabled = (residents.count == 0)
            tableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "confirmResident", let destination = segue.destination as? ConfirmResidentViewController {
            guard let _ = currentResidentIndex else { return }
//            destination.fullName = residents[currentResidentIndex].firstName + " " + residents[currentResidentIndex].lastName
//            destination.phone = residents[currentResidentIndex].phone
//            destination.email = residents[currentResidentIndex].email
//            destination.uniqueNumber = residents[currentResidentIndex].building!.buidingUniqueNumber
//            destination.buildingName = residents[currentResidentIndex].building!.name
//            destination.address = "\(residents[currentResidentIndex].suiteNumber) - \(residents[currentResidentIndex].building!.street!)\n\(residents[currentResidentIndex].building!.address)"
//            destination.residentId = residents[currentResidentIndex].id
            destination.resident = residents[currentResidentIndex]
        }
        if segue.identifier == "addOrphans", let destination = segue.destination as? AddOrphanParcelViewController {
            if let _ = fullName {
                if fullName != "" {
                    destination.line1 = fullName
                }
                if unitNumber != "" {
                    destination.line2 = unitNumber
                }
                if let _ = line3Address {
                    destination.line3Address = line3Address
                }
                if let _ = line4Street {
                    destination.line4Street = line4Street
                }
                
            }
        }
        
    }
    
}
//extension UIView {
//
//    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
//        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
//            constraint.constant = gone ? 0.0 : dimension
//            self.layoutIfNeeded()
//            self.isHidden = gone
//        }
//    }
//}
