//
//  AddResidentViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 28/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddResidentViewController: UIViewController, RestRequestsDelegate {
    
    @IBOutlet weak var lockersizeLabel: UILabel!
    @IBOutlet weak var lockeraddressLabel: UILabel!
    @IBOutlet weak var lockerNumberLabel: UILabel!
    @IBOutlet weak var lockerImage: UIImageView!
    
    var qrCode: String!
    let restRequest = RestRequests()
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        lockerImage.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        restRequest.delegate = self
        if qrCode != nil {
            let param = [
                KEY_qrCode: qrCode!,
                "expand": KEY_address + "." + KEY_city + "." + KEY_state
                ] as NSDictionary
            restRequest.checkForRequest(parameters: param, requestID: LOCKERS_REQUEST)
        }
       
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
