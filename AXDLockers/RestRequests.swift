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
    func resultedData(data: Data!, requestID: Int)
}

class RestRequests: NSObject {
    weak var delegate: RestRequestsDelegate?
    
    override init() {
        //init
    }
    
    func checkForRequest(parameters: NSDictionary!, requestID: Int){
        if UserDefaults.standard.object(forKey: "token") as? String == nil && requestID != TOKEN_REQUEST {
            Switcher.updateRootVC(isLogged: false)
            return
        }
        var mustRequestToken: Bool = false
        //UserDefaults.standard.set(1000.00 as! Double, forKey: "tokenExpiresAt")
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
                    addREST_Filter(parameters: [KEY_userEmail]): userEmail,
                    addREST_Filter(parameters: [KEY_password]): encryptedPassword
                ]
               
                Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
                    .validate()
                    .responseJSON(completionHandler: {response in
                        guard response.result.isSuccess else {
                            let message = "Connection error: \(String(describing: response.result.error!))"
                            let statusCode = response.response?.statusCode
                            self.delegate?.treatErrors(statusCode, errorMessage: message)
                            return
                        }
                        do {
                            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            let items = json[KEY_items] as! NSArray
                            let item = items[0] as! NSDictionary
                            UserDefaults.standard.set(item["accessToken"] as! String, forKey: "token")
                            UserDefaults.standard.set(item["tokenExpiresAt"] as! Double, forKey: "tokenExpiresAt")
                            switch (requestID) {
                            case LOCKERS_REQUEST:
                                self.getLockers(qrCode: parameters)
                                break
                            case CHECK_USERS_REQUEST:
                                let userId = parameters[KEY_userId] as! Int
                                self.checkUser(userId: userId)
                                break
                            case TOKEN_REQUEST:
                                self.delegate?.resultedData(data: response.data!, requestID: requestID)
                                break
                            case CITIES_REQUEST:
                                self.getCities(parameters: parameters)
                                break
                            case ADDRESSES_REQUEST:
                                self.getAddresses(parameters: parameters)
                                break
                            default:
                                print(requestID)
                            }
                
                            //mustRequestToken = false
                            
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
        }
        else {
            switch (requestID) {
            case LOCKERS_REQUEST:
                self.getLockers(qrCode: parameters)
                break
            case CHECK_USERS_REQUEST:
                let userId = parameters[KEY_userId] as! Int
                self.checkUser(userId: userId)
                break
            case TOKEN_REQUEST:
                UserDefaults.standard.removeObject(forKey: "tokenExpiresAt")
                break
            case CITIES_REQUEST:
                self.getCities(parameters: parameters)
                break
            case ADDRESSES_REQUEST:
                self.getAddresses(parameters: parameters)
                break
            default:
                print(requestID)
            }
        }

    }
//    func queryString(_ value: String, params: Parameters) -> String? {
//        var components = URLComponents(string: value)
//        components?.queryItems = params.mapValues{ element in URLQueryItem(name: (element as AnyObject).key!, value: (element as AnyObject).value) }
//        
//        return components?.url?.absoluteString
//    }
//    func postAddress(body: JSON){
//        var url: String = getURL()
//        url.append(contentsOf: citiesREST_Action)
//        
//        let param: Parameters = [
//            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
//            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
//        ]
//        let query = queryString(url, params: param)!
//        var request = URLRequest(url: URL(string: query)!)
//        request.httpMethod = HTTPMethod.post.rawValue
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let pjson = body.rawString()
//        let data = (pjson?.data(using: .utf8))! as Data
//        
//        request.httpBody = data
//    
//        Alamofire.request(request).responseJSON { (response) in
//            
//            
//            print(response)
//            
//        }
//        
//        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
//            .validate()
//            .responseJSON(completionHandler: {response in
//                guard response.result.isSuccess else {
//                    let message = "Connection error: \(String(describing: response.result.error!))"
//                    let statusCode = response.response?.statusCode
//                    self.delegate?.treatErrors(statusCode, errorMessage: message)
//                    return
//                }
//                self.delegate?.resultedData(data: response.data!, requestID: LOCKERS_REQUEST)
//            })
//    }
    func getLockers(qrCode: NSDictionary!){
        var url: String = getURL()
        url.append(contentsOf: lockersREST_Action)
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        if let qrCode = qrCode{
            param[addREST_Filter(parameters: [KEY_qrCode])] = qrCode[KEY_qrCode]
        }
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    let message = "Connection error: \(String(describing: response.result.error!))"
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: LOCKERS_REQUEST)
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
                self.delegate?.resultedData(data: response.data!, requestID: CHECK_USERS_REQUEST)
            })
    }

    func getCities(parameters: NSDictionary!) {
        var url: String = getURL()
        url.append(contentsOf: citiesREST_Action)
        var param: Parameters = [
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String,
            "expand": KEY_state,
            "sort": KEY_name
        ]
        if let parameters = parameters, parameters.count > 0 {
            if let likeName = parameters["likeName"] {
                param[addREST_Filter(parameters: [KEY_name, "like"])] = likeName
            }
            if let perPage = parameters["per-page"] {
                param["per-page"] = perPage
            }
            if let page = parameters["page"] {
                param["page"] = page
            }
        }
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    let message = "Connection error: \(String(describing: response.result.error!))"
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: CHECK_USERS_REQUEST)
            })
    }
    
    func getAddresses(parameters: NSDictionary!) {
        var url: String = getURL()
        url.append(contentsOf: addressesREST_Action)
        var param: Parameters = [
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String,
            "expand": KEY_city+"."+KEY_state,
            "sort": KEY_streetName
        ]
        if let parameters = parameters, parameters.count > 0 {
            if let likeStreetName = parameters["likeStreetName"] {
                param[addREST_Filter(parameters: [KEY_streetName, "like"])] = likeStreetName
            }
            if let perPage = parameters["per-page"] {
                param["per-page"] = perPage
            }
            if let page = parameters["page"] {
                param["page"] = page
            }
        }
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    let message = "Connection error: \(String(describing: response.result.error!))"
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: CHECK_USERS_REQUEST)
            })
    }
}
