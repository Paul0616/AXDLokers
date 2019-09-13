//
//  ChoseLockerMenuViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 12/09/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class ChoseLockerMenuViewController: UIViewController {

    @IBOutlet weak var scanQRButton: UIButton!
    @IBOutlet weak var searchLockerButton: UIButton!
    
    var resident: BuildingXResident!
    var addLockerOnly: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        alignTextBelow(button: scanQRButton)
        alignTextBelow(button: searchLockerButton)
        scanQRButton.layer.cornerRadius = 10
        searchLockerButton.layer.cornerRadius = 10
    }
    
    @IBAction func tapOnScanQR(_ sender: Any) {
        
    }
    @IBAction func tapOnSearchLocker(_ sender: Any) {
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "scanQRCode", let destination = segue.destination as? QRScannerViewController {
            destination.resident = resident
            destination.addLockerOnly = false
        }
    }
 

}
