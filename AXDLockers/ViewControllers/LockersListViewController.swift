//
//  LockersListViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 13/09/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LockersListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RestRequestsDelegate {
    
    
    
    var lockerNumber: String!
    var lockerStreet: String!
    var lockerZip: String!
    var lockerId: Int!
    var resident: BuildingXResident!
    var lockerHistory: LockerHistory!
    
    @IBOutlet weak var tableView: UITableView!
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
    var loadedPages: Int = 0
    let restRequest = RestRequests()
    var lockers: [Locker] = [Locker]()
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //activityIndicatorView = UIActivityIndicatorView(style: .gray)
        //activityIndicatorView.hidesWhenStopped = true
        //tableView.backgroundView = activityIndicatorView
        restRequest.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isLoading = true
        lockers.removeAll()
        activityIndicatorView.startAnimating()
        var param = [
            "per-page": PAGE_SIZE,
            "expand": KEY_address+"."+KEY_city+"."+KEY_state+"."+KEY_country+","+KEY_parcel,
            ] as Parameters
        if let _ = lockerNumber {
            param[KEY_number] = lockerNumber
        }
        if let _ = lockerStreet {
            param[KEY_streetName] = lockerStreet
        }
        if let _ = lockerZip {
            param[KEY_zipCode] = lockerNumber
        }
        restRequest.checkForRequest(parameters: param, requestID: MANUAL_LOCKERS_REQUEST)
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Locker occupied",
                                                message: "This locker appears in the system as not being free. So you can't choose this locker. Please choose another one.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        if let _ = errorCode {
            self.showToast(message: "Error code: \(errorCode!) - \(errorMessage)")
        }
    }
    
    func resultedData(data: Data!, requestID: Int) {
        activityIndicatorView.stopAnimating()
        isLoading = false
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
                let street = value[KEY_address][KEY_streetName].string!
                let zipCode = value[KEY_address][KEY_zipCode].string!
                let city = value[KEY_address][KEY_city][KEY_name].string!
                let state = value[KEY_address][KEY_city][KEY_state][KEY_name].string!
                let address = Address(street: street, id: value[KEY_address][KEY_id].int!, cityName: city, stateName: state, zipCode: zipCode)
                let lockerModel = Locker(id: value[KEY_id].int!, qrCode: value[KEY_qrCode].string!, number: value[KEY_number].string!, size: value[KEY_size].string!, address: address)
                var parcels = [Parcel]()
                for (_, parcelValue) in value[KEY_parcel]{
                    let parcel = Parcel(id: parcelValue[KEY_id].int!, lockerId: parcelValue[KEY_lockerId].int!, buildingResidentId: parcelValue[KEY_buildingResidentId].int!, securityCode: parcelValue[KEY_securityCode].string!, status: parcelValue[KEY_status].int!, buildingResident: nil, building: nil)
                    parcels.append(parcel)
                }
                lockerModel.parcels = parcels
                lockers.append(lockerModel)
            }
        }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lockers.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if lockers.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No locker with your search criteria"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lockerCell") as! LockerTableViewCell
        cell.lockerNumberLabel.text = lockers[indexPath.row].number
        cell.lockerSizeLabel.text = lockers[indexPath.row].size
        cell.lockerAddressLabel.text = lockers[indexPath.row].address.getAddressString()
        cell.lockedImageView.isHidden = lockers[indexPath.row].isLockerFree()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == lockers.count-1 && !isLoading && !isLastPage {
            //we are at the last cell and need to load more
            loadedPages = loadedPages + 1
            isLoading = true
            activityIndicatorView.startAnimating()
            var param = [
                "per-page": PAGE_SIZE,
                "expand": KEY_address+"."+KEY_city+"."+KEY_state+"."+KEY_country+","+KEY_parcel,
                "page" : loadedPages
                ] as Parameters
            if let _ = lockerNumber {
                param[KEY_number] = lockerNumber
            }
            if let _ = lockerStreet {
                param[KEY_streetName] = lockerStreet
            }
            if let _ = lockerZip {
                param[KEY_zipCode] = lockerNumber
            }
            restRequest.checkForRequest(parameters: param, requestID: MANUAL_LOCKERS_REQUEST)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lockers[indexPath.row].isLockerFree() {
            lockerId = lockers[indexPath.row].id
            lockerHistory = LockerHistory(locker: lockers[indexPath.row], resident: resident)
            performSegue(withIdentifier: "getLocker1", sender: nil)
        } else {
            showAlert()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "getLocker1" {
            let navigationcontroller = segue.destination as? UINavigationController
            let dest = navigationcontroller?.viewControllers.first as! SecurityCodeViewController
            dest.resident = resident
            dest.lockerId = lockerId
            dest.lockerHistory = lockerHistory
        }
    }
    

}
