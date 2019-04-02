//
//  AddAddressViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 26/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddAddressViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate, RestRequestsDelegate {
    
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var tableCities: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    
    var cities = [City]()
    //var cities: [String] = [String]()
    var selectedCityId: Int = 0
    let restRequests = RestRequests()
    let PAGE_SIZE: Int = 20
    var isLoading: Bool = false
    var isLastPage: Bool = true
    var loadedPages: Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        restRequests.delegate = self
        activityIndicator.startAnimating()
        saveBarButton.isEnabled = false
        isLoading = true
        let param = ["per-page": PAGE_SIZE] as NSDictionary
        restRequests.checkForRequest(parameters: param, requestID: CITIES_REQUEST)
    }
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        if streetTextField.text != "" && zipCodeTextField.text != "" && selectedCityId != 0 {
            print("\(streetTextField.text!) - \(zipCodeTextField.text!) - \(selectedCityId)")
            activityIndicator.startAnimating()
            isLoading = true
            //let now = (Date().timeIntervalSince1970 as Double).rounded()
            let param = [
                KEY_cityId: selectedCityId,
                KEY_zipCode: zipCodeTextField.text!,
                KEY_streetName: streetTextField.text!
                ] as [String : Any]
            restRequests.checkForRequest(parameters: param as NSDictionary, requestID: INSERT_ADDRESS_REQUEST)
        }
       //  self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: -  UITableView protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityTableViewCell
        cell.textLabel?.text = cities[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == cities.count-1 && !isLoading && !isLastPage {
            //we are at the last cell and need to load more
            loadedPages = loadedPages + 1
            let param = ["per-page": PAGE_SIZE, "page": loadedPages] as NSDictionary
            restRequests.checkForRequest(parameters: param, requestID: CITIES_REQUEST)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCityId = cities[indexPath.row].id
        makeButtonBarEnabled()
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedCityId = 0
        makeButtonBarEnabled()
    }
    //MARK: -  UISearchBar protocol
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        selectedCityId = 0
        makeButtonBarEnabled()
        cities.removeAll()
        activityIndicator.startAnimating()
        isLoading = true
        let param = ["likeName": searchBar.text!, "per-page": PAGE_SIZE, "page": loadedPages] as NSDictionary
        restRequests.checkForRequest(parameters: param, requestID: CITIES_REQUEST)
    }
    //MARK: - ButtonBarEnabled
    func makeButtonBarEnabled(){
        if streetTextField.text != "" && zipCodeTextField.text != "" && selectedCityId != 0 {
            saveBarButton.isEnabled = true
        } else {
            saveBarButton.isEnabled = false
        }
    }
    //MARK: - UItextfieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        if textField == streetTextField {
            zipCodeTextField.becomeFirstResponder()
            makeButtonBarEnabled()
        }
        
        if textField == zipCodeTextField {
            textField.resignFirstResponder()
            makeButtonBarEnabled()
            //attemptLogin()
        }
        return true
    }
    
    //MARK: - RestRequest protocol
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        isLoading = false
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        activityIndicator.stopAnimating()
        isLoading = false
        let json = try? JSON(data: data)
        print(requestID)
        if requestID == CITIES_REQUEST {
            if let meta: JSON = getMeta(json: json) {
                let currentPage = meta["currentPage"].int
                if loadedPages != currentPage {
                    loadedPages = currentPage!
                }
            }
            isLastPage = isLastPageLoaded(json: json)
            if let items: JSON = getItems(json: json), items.count > 0 {
                for (_, value) in items {
                    let state = value[KEY_state][KEY_name].string!
                    let cityId = value[KEY_id].int!
                    let city = City.init(name: value[KEY_name].string! + ", " + state, id: cityId)!
                    cities.append(city)
                }
            }
            if cities.count == 0 {
                let city = City.init(name: "No available cities", id: 0)!
                cities.append(city)
            }
            tableCities.reloadData()
        }
        if requestID == INSERT_ADDRESS_REQUEST {
            if json!.count > 0 {
                let alertController = UIAlertController(title: "Address added",
                                                        message: "Address was succsesfully added.",
                    preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    print("OK")
                    self.navigationController?.popViewController(animated: true)
                    
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
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
