//
//  restRequests.swift
//  AXDLockers
//
//  Created by Paul Oprea on 21/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


protocol RestRequestsDelegate: class {
    func treatErrors(_ errorCode: Int!, errorMessage: String)
    func tokenWasReceived(tokenJSON: NSArray!, requestID: Int)
    func resultedData(data: Data!)
    //    func getLocation(_ location: CLLocation)
    //    func isLocationAvailable(_ isLocationAvailable: Bool, status: CLAuthorizationStatus?)
}
class RestRequests: NSObject {
    weak var delegate: RestRequestsDelegate?
    
    override init() {
        //init
    }
    
    func checkForRequest(parameters: NSDictionary, requestID: Int){
        if UserDefaults.standard.object(forKey: "token") as? String == nil {
            Switcher.updateRootVC(isLogged: false)
            return
        }
        var mustRequestToken: Bool = false
        if let tokenExpiresAt = UserDefaults.standard.object(forKey: "tokenExpiresAt") as? Double {
            let now = (Date().timeIntervalSince1970 as Double).rounded()
            if now > tokenExpiresAt {
                mustRequestToken = true
                
            }
        } else {
            mustRequestToken = true
        }
        
        
        if mustRequestToken {
            if let userEmail = UserDefaults.standard.object(forKey: "userEmail") as? String, let encryptedPassword = UserDefaults.standard.object(forKey: "encryptedPassword") as? String {
                var url: String = getURL()
                url.append(contentsOf: tokensREST_Action)
                let param: Parameters = [
                    addREST_Filter(parameters: [emailREST_Key]): userEmail,
                    addREST_Filter(parameters: [passwordREST_Key]): encryptedPassword
                ]
               
                Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
                    .validate()
                    .responseJSON(completionHandler: {response in
                        guard response.result.isSuccess else {
                            let message = "Internet appear to be offline: \(String(describing: response.result.error!))"
                            let statusCode = response.response?.statusCode
                            self.delegate?.treatErrors(statusCode, errorMessage: message)
                            return
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            let items = json["items"] as! NSArray
                            let item = items[0] as! NSDictionary
                            UserDefaults.standard.set(item["accessToken"] as! String, forKey: "token")
                            UserDefaults.standard.set(item["tokenExpiresAt"] as! Double, forKey: "tokenExpiresAt")
                            switch (requestID) {
                            case LOCKERS_REQUEST:
                                self.getLockers(qrCode: parameters)
                                break
                            default:
                                print(requestID)
                            }
                
                            
                            
                        }  catch let error as NSError
                        {
                            print(error.localizedDescription)
                            let message = "Incorrect received data"
                            let statusCode = response.response?.statusCode
                            self.delegate?.treatErrors(statusCode, errorMessage: message)
                            return
                        }
                    })
            } else {
                print("userEmail or encryptedPassword in not set")
                Switcher.updateRootVC(isLogged: false)
            }
        } else {
            switch (requestID) {
            case LOCKERS_REQUEST:
                self.getLockers(qrCode: parameters)
                break
            default:
                print(requestID)
            }
        }

    }
    
    func getLockers(qrCode: NSDictionary){
        var url: String = getURL()
        url.append(contentsOf: lockersREST_Action)
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        
        param[addREST_Filter(parameters: [qrCodeREST_Key])] = qrCode[qrCodeREST_Key]
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    let message = "Connection error: \(String(describing: response.result.error!))"
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!)
            })
    }
    
    func checkUser(userId: Int) {
        var url: String = getURL()
        url.append(contentsOf: usersREST_Action)
        url.append(contentsOf: "/\(userId)")
        let param: Parameters = [
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    let message = "Error while fetching user(\(userId)): \(String(describing: response.result.error!))"
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!)
            })
    }
    func getNewToken(userEmail: String, encryptedPassword: String, requestId: Int){
        var url: String = getURL()
        url.append(contentsOf: tokensREST_Action)
        let param: Parameters = [
            addREST_Filter(parameters: [emailREST_Key]): userEmail,
            addREST_Filter(parameters: [passwordREST_Key]): encryptedPassword
        ]
        //    url.append(contentsOf: addREST_Filter(parameters: [emailREST_Action], value: userEmail))
        //    url.append(contentsOf: "&")
        //    url.append(contentsOf: addREST_Filter(parameters: [passwordREST_Action], value: encryptedPassword))
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    let message = "Error while fetching token: \(String(describing: response.result.error!))"
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!)
                
            })
    }
}
