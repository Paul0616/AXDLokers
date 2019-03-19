//
//  Switcher.swift
//  AXDLockers
//
//  Created by Paul Oprea on 19/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import Foundation
import UIKit

class Switcher {
    
    static func updateRootVC(){
        
        let userId: Int! = UserDefaults.standard.object(forKey: "userId") as? Int
        var rootVC : UIViewController?
        
        print(userId)
        
        
        if(userId == nil || userId == 0){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginScreen") as! LogInViewController
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "initController") as! QRScannerViewController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
        appDelegate.window?.makeKeyAndVisible()
    }
    
}

