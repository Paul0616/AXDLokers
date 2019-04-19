//
//  ChooseAddressViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 27/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChooseAddressViewController: UITableViewController, UISearchBarDelegate, RestRequestsDelegate {
    
    
    let restRequests = RestRequests()
    var addresses: [Address] = [Address]()
    var activityIndicatorView: UIActivityIndicatorView!
    var selectedAddressId: Int = 0
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
    var loadedPages: Int = 0
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        restRequests.delegate = self
        activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        tableView.backgroundView = activityIndicatorView
        tableView.estimatedRowHeight = 85
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addresses.removeAll()
        isLoading = true
        activityIndicatorView.startAnimating()
        let param = ["per-page": PAGE_SIZE] as NSDictionary
        restRequests.checkForRequest(parameters: param, requestID: ADDRESSES_REQUEST)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isBeingDismissed {
            var controller: UINavigationController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "navigationAddLocker") as! UINavigationController
            let dest = controller.viewControllers.first as! AddLockerViewController
            dest.address = addresses[tableView.indexPathForSelectedRow!.row]
//            let filterVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "demoViewController")
//            filterVC.modalPresentationStyle = UIModalPresentationStyle.custom
//            print("called")
            self.presentingViewController?.present(dest, animated: true, completion: nil)
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        var numOfSections: Int = 0
        if addresses.count > 0
        {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        }
        else
        {
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No available addresses"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return addresses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell

        // Configure the cell...
        cell.streetNameLabel?.text = addresses[indexPath.row].street
        cell.cityNameLabel?.text = addresses[indexPath.row].cityName + ", " + addresses[indexPath.row].stateName
        cell.zipCodeLabel?.text = addresses[indexPath.row].zipCode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == addresses.count-1 && !isLoading && !isLastPage {
            //we are at the last cell and need to load more
            loadedPages = loadedPages + 1
            let param = ["per-page": PAGE_SIZE, "page": loadedPages] as NSDictionary
            restRequests.checkForRequest(parameters: param, requestID: ADDRESSES_REQUEST)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAddressId = addresses[indexPath.row].id
        if selectedAddressId == 0 {
            return
        }
        let userDefaults = UserDefaults.standard
        do {
        let encodedData: Data = try NSKeyedArchiver.archivedData(withRootObject: addresses[indexPath.row], requiringSecureCoding: false)
        userDefaults.set(encodedData, forKey: "address")
        userDefaults.synchronize()
        } catch {
            print("can't save current address")
        }
        self.dismiss(animated: false, completion:  nil)
    }
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 85
//    }
    
    //MARK: -  UISearchBar protocol
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        selectedAddressId = 0
        addresses.removeAll()
        activityIndicatorView.startAnimating()
        isLoading = true
        let param = ["likeStreetName": searchBar.text!, "per-page": PAGE_SIZE, "page": loadedPages] as NSDictionary
        restRequests.checkForRequest(parameters: param, requestID: ADDRESSES_REQUEST)
    }
   
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        isLoading = false
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        activityIndicatorView.stopAnimating()
        isLoading = false
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
                let street = value[KEY_streetName].string!
                let city = value[KEY_city][KEY_name].string!
                let state = value[KEY_city][KEY_state][KEY_name].string!
                let addressId = value[KEY_id].int!
                let zipCode = value[KEY_zipCode].string!
                let address = Address.init(street: street, id: addressId, cityName: city, stateName: state, zipCode: zipCode)
                addresses.append(address)
            }
        }
//        if addresses.count == 0 {
//            let address = Address.init(street: "No available address", id: 0, cityName: "", stateName: "", zipCode: "")
//            addresses.append(address)
            
//        }
        tableView.reloadData()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
