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
    
    @IBOutlet weak var sendButtonBar: UIBarButtonItem!
    var noDataMessage: String = "No available residents"
    var qrCode: String!
    var currentBuildingId: Int!
    var currentLockerId: Int!
    var currentLockerHistory: LockerHistory!
    let restRequest = RestRequests()
    var residents: [Resident] = [Resident]()
    
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
//    var isFiltered: Bool = false
    var loadedPages: Int = 0
    var selectedResident: Resident!
    var ownedBuildingsUniqueNumbers: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        lockerImage.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        restRequest.delegate = self
        searchBar.delegate = self
        refreshButton()
        checkUser()
       
    }
    

    @IBAction func onTapViewBuilding(_ sender: UITapGestureRecognizer) {
        buildingAddressLabel.text = "-"
        buldingUniqueNumberLabel.text = "-"
        performSegue(withIdentifier: "chooseBuildingSegue", sender: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.removeObject(forKey: "codeWasdetected")
        
    }
    
    @IBAction func onSend(_ sender: Any) {
        print("\(selectedResident.firstName) have ID=\(selectedResident.id)")
        print("locker id=\(currentLockerId!)")
        performSegue(withIdentifier: "getSecurityCodeSegue", sender: nil)
    }
    @IBAction func onCancel(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    func checkUser(){
        if let userId: Int = UserDefaults.standard.object(forKey: "userId") as? Int {
            let param = [KEY_userId: userId] as NSDictionary
            restRequest.checkForRequest(parameters: param, requestID: CHECK_USERS_REQUEST)
        }
    }
    func refreshBuilding(){
        if qrCode != nil {
            activityIndicator.startAnimating()
            isLoading = true
            isLastPage = true
            loadedPages = 0
            residents.removeAll()
            let param = [
                KEY_qrCode: qrCode!,
                "expand": KEY_address + "." + KEY_city + "." + KEY_state
                ] as NSDictionary
            restRequest.checkForRequest(parameters: param, requestID: LOCKERS_REQUEST)
        }
    }
    func refreshButton(){
        if selectedResident != nil && selectedResident.id != 0 {
            sendButtonBar.isEnabled = true
        } else {
            sendButtonBar.isEnabled = false
        }
    }
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        print(requestID)
        if requestID == CHECK_USERS_REQUEST {
            let json = try? JSON(data: data)
            if let role: JSON = getJSON(json: json, desiredKey: KEY_role) {
                let hasRelatedBuilding: Bool = role[KEY_hasRelatedBuildings].int == 1 ? true : false
                if hasRelatedBuilding {
                    let buildingXUsers: JSON = getJSON(json: json, desiredKey: KEY_buildingXUsers)
                    if buildingXUsers.count == 0 {
                        let alertController = UIAlertController(title: "No building", message: "You've not been assigned any building. Please contact your administrator.\nYou'll be redirected to the login screen.", preferredStyle: UIAlertController.Style.alert)
                        let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                            Switcher.updateRootVC(isLogged: true)
                        })
                        alertController.addAction(saveAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        ownedBuildingsUniqueNumbers = [String]()
                        for (_, value) in buildingXUsers {
                            let buildingUniqueNumber = value[KEY_building][KEY_buildingUniqueNumber].string!
                            ownedBuildingsUniqueNumbers.append(buildingUniqueNumber)
                        }
                        refreshBuilding()
                    }
                } else {
                    refreshBuilding()
                }
                
            }
        }
        
        if requestID == LOCKERS_REQUEST {
            if let items: JSON = getJSON(json: json, desiredKey: KEY_items), items.count > 0 {
                for (_, value) in items {
                    currentLockerId = value[KEY_id].int
                    lockerNumberLabel.text = "#"+value[KEY_number].string!
                    lockersizeLabel.text = value[KEY_size].string!
                    let street = value[KEY_address][KEY_streetName].string!
                    let city = value[KEY_address][KEY_city][KEY_name].string!
                    let state = value[KEY_address][KEY_city][KEY_state][KEY_name].string!
                    let zipCode = value[KEY_address][KEY_zipCode].string!
                    lockeraddressLabel.text = street+", "+city+", "+state+", "+zipCode
                    currentLockerHistory = LockerHistory(qrCode: value[KEY_qrCode].string!, lockerAddress: lockeraddressLabel.text!, number: value[KEY_number].string!, size: value[KEY_size].string!, firstName: "", lastName: "", email: "", phoneNumber: nil, residentAddress: "", suiteNumber: "", buildingUniqueNumber: "", name: "", buildingAddress: "")
                    break
                }
                noDataMessage = "No available residents"
                if currentBuildingId == nil {
                    let param = [KEY_qrCode: qrCode!] as NSDictionary
                    restRequest.checkForRequest(parameters: param, requestID: LOCKER_HISTORY_REQUEST, list: ownedBuildingsUniqueNumbers)
                } else {
                    let param = [KEY_id: currentBuildingId!, "expand": KEY_address + "." + KEY_city + "." + KEY_state] as NSDictionary
                    restRequest.checkForRequest(parameters: param, requestID: BUILDING_ID_REQUEST)
                }
            }
        }
        if requestID == LOCKER_HISTORY_REQUEST {
            buldingUniqueNumberLabel.text = "-"
            buildingAddressLabel.text = "-"
            if let items: JSON = getJSON(json: json, desiredKey: KEY_items){
                for (_, value) in items {
                    buldingUniqueNumberLabel.text = value[KEY_buildingUniqueNumber].string!
                    buildingAddressLabel.text = value[KEY_name].string! + ", " + value[KEY_buildingAddress].string!
                    currentLockerHistory.buildingUniqueNumber = value[KEY_buildingUniqueNumber].string!
                    currentLockerHistory.name = value[KEY_name].string!
                    currentLockerHistory.buildingAddress = value[KEY_buildingAddress].string!
                    currentLockerHistory.residentAddress = currentLockerHistory.buildingAddress
                    break
                }
                if  buldingUniqueNumberLabel.text != "-" {
                    
                    let param = [KEY_buildingUniqueNumber: buldingUniqueNumberLabel.text!] as NSDictionary
                    restRequest.checkForRequest(parameters: param, requestID: BUILDING_REQUEST)
                } else {
                    noDataMessage = """
                    You have to choose a building
                    to see its residents
                    """
                    activityIndicator.stopAnimating()
                    tableResidents.reloadData()
//                    let param = ["per-page": PAGE_SIZE]
//                    restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_FILTERED_RESIDENTS_REQUEST)
                }
            }
        }
        if requestID == BUILDING_REQUEST {
            if let items: JSON = getJSON(json: json, desiredKey: KEY_items), items.count > 0 {
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
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_FILTERED_RESIDENTS_REQUEST)
        }
        
        if requestID == BUILDING_ID_REQUEST {
            if json!.count > 0 {
                buldingUniqueNumberLabel.text = json![KEY_buildingUniqueNumber].string!
                buildingAddressLabel.text = json![KEY_name].string! + ", " + json![KEY_address][KEY_streetName].string! + ", " + json![KEY_address][KEY_city][KEY_name].string! + ", " + json![KEY_address][KEY_city][KEY_state][KEY_name].string!
                currentLockerHistory.buildingUniqueNumber = json![KEY_buildingUniqueNumber].string!
                currentLockerHistory.name = json![KEY_name].string!
                currentLockerHistory.buildingAddress = json![KEY_address][KEY_streetName].string! + ", " + json![KEY_address][KEY_city][KEY_name].string! + ", " + json![KEY_address][KEY_city][KEY_state][KEY_name].string!
                currentLockerHistory.residentAddress = currentLockerHistory.buildingAddress
            } else {
                buldingUniqueNumberLabel.text = "-"
                buildingAddressLabel.text = "-"
                currentLockerHistory.name = ""
                currentLockerHistory.buildingAddress = ""
                currentLockerHistory.residentAddress = ""
            }
            var param = ["per-page": PAGE_SIZE]
            if currentBuildingId != nil {
                param[KEY_buildingId] = currentBuildingId!
            }
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_FILTERED_RESIDENTS_REQUEST)
        }
        
        if requestID == GET_FILTERED_RESIDENTS_REQUEST {
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
                    guard let buildingResidentId = value[KEY_id].int else { return  }
                    let suiteNumber = value[KEY_suiteNumber].string!
                    let firstName = value[KEY_resident][KEY_firstName].string!
                    let lastName = value[KEY_resident][KEY_lastName].string!
                    var phone = "-"
                    if value[KEY_resident][KEY_phone].type != SwiftyJSON.Type.null {
                        phone = value[KEY_resident][KEY_phone].string!
                    }
                    let email = value[KEY_resident][KEY_email].string!
                    //let securityCode = value[KEY_resident][KEY_securityCode].string!
                    
                    let resident = Resident(id: id, firstName: firstName, lastName: lastName, phone: phone, email: email, suiteNumber: suiteNumber, buildingResidentId: buildingResidentId)
                    residents.append(resident)
                }
            }
//            if residents.count == 0 {
//                let resident = Resident(id: 0, firstName: "", lastName: " ", phone: "", email: "", securityCode: "", suiteNumber: "No available residents", buildingResidentId: 0)
//                residents.append(resident)
//            }
            tableResidents.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if residents.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = noDataMessage
            noDataLabel.numberOfLines = 2
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellResident") as! ResidentTableViewCell
        cell.residentNameLabel.text = residents[indexPath.row].firstName + " " + residents[indexPath.row].lastName
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
                param[KEY_suiteNumber] = searchBar.text!
            }
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_FILTERED_RESIDENTS_REQUEST)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedResident = residents[indexPath.row]
        currentLockerHistory.firstName = selectedResident.firstName
        currentLockerHistory.lastName = selectedResident.lastName
        currentLockerHistory.email = selectedResident.email
        currentLockerHistory.phoneNumber = selectedResident.phone
        //currentLockerHistory.securityCode = selectedResident.securityCode
        currentLockerHistory.suiteNumber = selectedResident.suiteNumber
        self.refreshButton()
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
            param[KEY_suiteNumber] = searchBar.text!
        }
        restRequest.checkForRequest(parameters: param as NSDictionary, requestID: GET_FILTERED_RESIDENTS_REQUEST)
    }
    @IBAction func unwindToResidents(sender: UIStoryboardSegue) {
      
        if let sourceViewController = sender.source as? ChooseBuildingViewController {
            currentBuildingId = sourceViewController.selectedBuildingId
            refreshButton()
            refreshBuilding()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.let
        if let dest = segue.destination  as? SecurityCodeViewController {
            dest.lockerHistory = currentLockerHistory!
            dest.resident = selectedResident!
            dest.lockerId = currentLockerId!
        }
    }
    

}
