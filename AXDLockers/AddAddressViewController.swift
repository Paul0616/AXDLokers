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
    
    var cities: [String] = [String]()
    let restRequests = RestRequests()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        restRequests.delegate = self
        activityIndicator.startAnimating()
        restRequests.checkForRequest(parameters: nil, requestID: CITIES_REQUEST)
    }
    //MARK: -  UITableView protocol
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityTableViewCell
        cell.textLabel?.text = cities[indexPath.row]
        return cell
    }
    //MARK: -  UISearchBar protocol
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - UItextfieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //hide keyboard
        if textField == streetTextField {
            zipCodeTextField.becomeFirstResponder()
        }
        
        if textField == zipCodeTextField {
            textField.resignFirstResponder()
            //attemptLogin()
        }
        return true
    }
    
    //MARK: - RestRequest protocol
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        do {
            activityIndicator.stopAnimating()
            let json = try? JSON(data: data)
            if json!.count > 0 {
                for element in json! {
                    print(element)
                }
            }
            if json?["createdBy"].type == SwiftyJSON.Type.string {
                print("string")
            }
            if json?["createdBy"].type == SwiftyJSON.Type.null {
                print("null")
            }
            let json1 = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let items = json1["items"] as! NSArray
            
            if items.count > 0 {
                for item in items {
                    print(item)
//                    if let object = item as! NSDictionary {
//                        cities.append(object["name"] as String)
//                    }
                }
            }
            
        } catch let error as NSError
        {
            print(error)
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
