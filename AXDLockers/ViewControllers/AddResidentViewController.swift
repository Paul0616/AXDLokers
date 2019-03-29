//
//  AddResidentViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 28/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddResidentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, RestRequestsDelegate {
    
    
    
    @IBOutlet weak var lockersizeLabel: UILabel!
    @IBOutlet weak var lockeraddressLabel: UILabel!
    @IBOutlet weak var lockerNumberLabel: UILabel!
    @IBOutlet weak var lockerImage: UIImageView!
    @IBOutlet weak var viewBuilding: UIView!
    @IBOutlet weak var buldingUniqueNumberLabel: UILabel!
    @IBOutlet weak var buildingAddressLabel: UILabel!
    @IBOutlet weak var tableResidents: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var qrCode: String!
    var currentBuildingId: Int!
    let restRequest = RestRequests()
    var residents: [Resident] = [Resident]()
    var filteredResidents: [Resident] = [Resident]()
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
//    var isFiltered: Bool = false
    var loadedPages: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        lockerImage.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        restRequest.delegate = self
        searchBar.delegate = self
        if qrCode != nil {
            activityIndicator.startAnimating()
            isLoading = true
            let param = [
                KEY_qrCode: qrCode!,
                "expand": KEY_address + "." + KEY_city + "." + KEY_state
                ] as NSDictionary
            restRequest.checkForRequest(parameters: param, requestID: LOCKERS_REQUEST)
        }
       
    }
    

    @IBAction func onTapViewBuilding(_ sender: UITapGestureRecognizer) {
        print("TAAAAAAP")
    }
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.removeObject(forKey: "codeWasdetected")
    }
    
    @IBAction func onCancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        print(requestID)
        if requestID == LOCKERS_REQUEST {
            if let items: JSON = getItems(json: json), items.count > 0 {
                for (_, value) in items {
                    lockerNumberLabel.text = "#"+value[KEY_number].string!
                    lockersizeLabel.text = value[KEY_size].string!
                    let street = value[KEY_address][KEY_streetName].string!
                    let city = value[KEY_address][KEY_city][KEY_name].string!
                    let state = value[KEY_address][KEY_city][KEY_state][KEY_name].string!
                    let zipCode = value[KEY_address][KEY_zipCode].string!
                    lockeraddressLabel.text = street+", "+city+", "+state+", "+zipCode
                    break
                }
                let param = [KEY_qrCode: qrCode!] as NSDictionary
                restRequest.checkForRequest(parameters: param, requestID: LOCKER_HISTORY_REQUEST)
            }
        }
        if requestID == LOCKER_HISTORY_REQUEST {
            buldingUniqueNumberLabel.text = "-"
            buildingAddressLabel.text = "-"
            if let items: JSON = getItems(json: json){
                for (_, value) in items {
                    buldingUniqueNumberLabel.text = value[KEY_buildingUniqueNumber].string!
                    buildingAddressLabel.text = value[KEY_buildingAddress].string!
                    break
                }
                if  buldingUniqueNumberLabel.text != "-" {
                    let param = [KEY_buildingUniqueNumber: buldingUniqueNumberLabel.text!] as NSDictionary
                    restRequest.checkForRequest(parameters: param, requestID: BUILDING_REQUEST)
                } else {
                    let param = ["per-page": PAGE_SIZE]
                    restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_BY_BUILDING_REQUEST)
                }
            }
        }
        if requestID == BUILDING_REQUEST {
            if let items: JSON = getItems(json: json), items.count > 0 {
                for (_, value) in items {
                    currentBuildingId = value[KEY_id].int!
                    break
                }
            } else {
                buldingUniqueNumberLabel.text = "-"
                buildingAddressLabel.text = "-"
            }
            var param = ["per-page": PAGE_SIZE]
            if currentBuildingId != nil {
                param[KEY_buildingId] = currentBuildingId!
            }
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_BY_BUILDING_REQUEST)
        }
        if requestID == GET_BY_BUILDING_REQUEST {
            isLoading = false
            activityIndicator.stopAnimating()
            let json = try? JSON(data: data)
            if let meta: JSON = getMeta(json: json) {
                let currentPage = meta["currentPage"].int
                if loadedPages != currentPage {
                    loadedPages = currentPage!
                }
            }
            isLastPage = isLastPageLoaded(json: json)
            if let items: JSON = getItems(json: json), items.count > 0 {
                for (_, value) in items {
                    guard let id = value[KEY_id].int else { return  }
                    let suiteNumber = value[KEY_buildingXResidents][0][KEY_suiteNumber].string!
                    let firstName = value[KEY_firstName].string!
                    let lastName = value[KEY_lastName].string!
                    var phone = "-"
                    if value[KEY_phone].type != SwiftyJSON.Type.null {
                        phone = value[KEY_phone].string!
                    }
                    let email = value[KEY_email].string!
                    let securityCode = value[KEY_securityCode].string!
                    
                    let resident = Resident(id: id, name: firstName + " " + lastName, phone: phone, email: email, securityCode: securityCode, suiteNumber: suiteNumber)
                    residents.append(resident)
                }
            }
            tableResidents.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellResident") as! ResidentTableViewCell
        cell.residentNameLabel.text = residents[indexPath.row].name
        cell.suiteNumberLabel.text = residents[indexPath.row].suiteNumber
        cell.phoneLabel.text = residents[indexPath.row].phone
        cell.emailLabel.text = residents[indexPath.row].email
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == residents.count-1 && !isLoading && !isLastPage  { //&& !isFiltered
            //we are at the last cell and need to load more
            loadedPages = loadedPages + 1
            activityIndicator.startAnimating()
            isLoading = true
            var param = ["per-page": PAGE_SIZE, "page": loadedPages] as [String:Any]
            if currentBuildingId != nil {
                param[KEY_buildingId] = currentBuildingId!
            }
            if searchBar.text != "" {
                param[KEY_residentName] = searchBar.text!
            }
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_BY_BUILDING_REQUEST)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       // tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    //MARK: -  UISearchBar protocol
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        residents.removeAll()
        activityIndicator.startAnimating()
        isLoading = true
        isLastPage = true
        var param = ["per-page": PAGE_SIZE, "page": loadedPages] as [String:Any]
        if currentBuildingId != nil {
            param[KEY_buildingId] = currentBuildingId!
        }
        if searchBar.text != "" {
            param[KEY_residentName] = searchBar.text!
        }
        restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_BY_BUILDING_REQUEST)
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
