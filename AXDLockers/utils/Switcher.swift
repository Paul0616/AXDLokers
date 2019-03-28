//
//  Switcher.swift
//  AXDLockers
//
//  Created by Paul Oprea on 19/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Switcher {
    
    
    
    static func updateRootVC(isLogged: Bool){
        
        var rootVC : UIViewController?
        if let userId = UserDefaults.standard.object(forKey: "userId") as? Int {
            print("userId=\(userId)")
        } else {
            print("userId not set")
        }
        
        
        
        if(!isLogged){ //user is not logged
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScreen") as! LogInViewController
        } else { //check if still logged and get new token if is neccesary
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "initController") as! QRScannerViewController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
        appDelegate.window?.makeKeyAndVisible()
    }
    
    
}

