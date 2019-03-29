//
//  ChooseBuildingViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 29/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChooseBuildingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, RestRequestsDelegate {
    var currentBuildingId: Int!
    let restRequest = RestRequests()
    
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
    //    var isFiltered: Bool = false
    var loadedPages: Int = 0
    var buildings: [Building] = [Building]()
    var selectedBuildingId: Int!
    
    @IBOutlet weak var tableBuildings: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Choose Condo Buildings"
        searchBar.delegate = self
        restRequest.delegate = self
        activityIndicator.startAnimating()
        isLoading = true
        let param = ["expand": KEY_address + "." + KEY_city + "." + KEY_state, "per-page": PAGE_SIZE] as NSDictionary
        restRequest.checkForRequest(parameters: param, requestID: BUILDING_REQUEST)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellBuildings") as! BuildingTableViewCell
        cell.addressLabel.text = buildings[indexPath.row].name + ", " + buildings[indexPath.row].address
        cell.buildingUniqueNumberLabel.text = buildings[indexPath.row].buidingUniqueNumber
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == buildings.count-1 && !isLoading && !isLastPage  { //&& !isFiltered
            //we are at the last cell and need to load more
            loadedPages = loadedPages + 1
            activityIndicator.startAnimating()
            isLoading = true
            var param = ["expand": KEY_address + "." + KEY_city + "." + KEY_state, "per-page": PAGE_SIZE, "page": loadedPages] as [String: Any]
            if searchBar.text != "" {
                param[KEY_searchText] = searchBar.text!
            }
            restRequest.checkForRequest(parameters: param as NSDictionary, requestID: BUILDING_REQUEST)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedBuildingId = buildings[indexPath.row].id
        // tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    //MARK: -  UISearchBar protocol
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        buildings.removeAll()
        activityIndicator.startAnimating()
        isLoading = true
        isLastPage = true
        var param = ["per-page": PAGE_SIZE, "page": loadedPages, "expand": KEY_address + "." + KEY_city + "." + KEY_state] as [String:Any]
        if searchBar.text != "" {
            param[KEY_searchText] = searchBar.text!
        }
        restRequest.checkForRequest(parameters: param as NSDictionary, requestID: BUILDING_REQUEST)
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
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
                let buildingUniqueNumber = value[KEY_buildingUniqueNumber].string!
                let name = value[KEY_name].string!
                let address = value[KEY_address][KEY_streetName].string! + ", " + value[KEY_address][KEY_city][KEY_name].string! + ", " + value[KEY_address][KEY_city][KEY_state][KEY_name].string! + ", " + value[KEY_address][KEY_zipCode].string!
                
                let building = Building(id: id, name: name, address: address, buidingUniqueNumber: buildingUniqueNumber)
                buildings.append(building)
            }
        }
        tableBuildings.reloadData()
    }
   
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        print("dufhsdui")
    }
  

}
