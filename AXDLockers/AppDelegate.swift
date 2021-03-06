//
//  AppDelegate.swift
//  AXDLokers
//
//  Created by Paul Oprea on 18/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RestRequestsDelegate {
   
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        
        if json?["createdBy"].type == SwiftyJSON.Type.string {
            print("string")
        }
        if json?["createdBy"].type == SwiftyJSON.Type.null {
            print("null")
        }
        if let role: JSON = getJSON(json: json, desiredKey: KEY_role) {
            let hasRelatedBuilding: Bool = role[KEY_hasRelatedBuildings].int == 1 ? true : false
            if hasRelatedBuilding {
                let buildingXUsers: JSON = getJSON(json: json, desiredKey: KEY_buildingXUsers)
                if buildingXUsers.count == 0 {
                    let alertController = UIAlertController(title: "No building", message: "You've not been assigned any building. Please contact your administrator.\nYou'll be redirected to the login screen.", preferredStyle: UIAlertController.Style.alert)
                    let saveAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                        Switcher.updateRootVC(isLogged: false)
                    })
                    alertController.addAction(saveAction)
                    let topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
                    topWindow?.rootViewController = UIViewController()
                    topWindow?.windowLevel = UIWindow.Level.alert + 1
                    topWindow?.makeKeyAndVisible()
                    topWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                } else {
                   Switcher.updateRootVC(isLogged: true)
                }
            } else {
                Switcher.updateRootVC(isLogged: true)
            }

        }
       
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorCode!)
        if errorCode == 401 {
            UserDefaults.standard.removeObject(forKey: "token")
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "isSuperAdmin")
            UserDefaults.standard.removeObject(forKey: "tokenExpiresAt")
            UserDefaults.standard.removeObject(forKey: "encryptedPassword")
        }
        Switcher.updateRootVC(isLogged: false)
    }


    var window: UIWindow?
    let restRequests = RestRequests()
    
    
    //MARK: - Launcher Screen
    private func splashScreen(){
        let launchScreenVC = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        let rootVC = launchScreenVC.instantiateViewController(withIdentifier: "splashScreen")
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(dismissSplashController), userInfo: nil, repeats: false)
    }
    @objc func dismissSplashController(){
        let userId: Int! = UserDefaults.standard.object(forKey: "userId") as? Int
        //let wasLogged = userId != nil && userId != 0
        if userId == nil || userId == 0 {
            //userId is not set or zero go to login screen
            Switcher.updateRootVC(isLogged: false)
        } else {
            let param = [KEY_userId: userId!] as NSDictionary
            restRequests.checkForRequest(parameters: param, requestID: CHECK_USERS_REQUEST)
        }
    }

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       
        restRequests.delegate = self
        self.splashScreen()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


