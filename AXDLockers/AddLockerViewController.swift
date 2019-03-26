//
//  AddLockerViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 25/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class AddLockerViewController: UIViewController {

    @IBOutlet weak var lockerImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        lockerImage.tintColor = UIColor(red:0.70, green:0.76, blue:1.00, alpha:1.0)
        // Do any additional setup after loading the view.
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
