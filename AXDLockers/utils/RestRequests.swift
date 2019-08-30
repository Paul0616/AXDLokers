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
    
    func checkForRequest(parameters: NSDictionary!, requestID: Int, list: [String] = [String](), param1: NSDictionary! = nil){
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
                            var message = ""
                            if let errorData = response.data {
                                if let json = try? JSON(data: errorData) {
                                    message = json["message"].string!
                                }
                            } else {
                                message = "Connection error: \(String(describing: response.result.error!))"
                            }
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
                            UserDefaults.standard.set(item["id"] as! Int, forKey: "userId")
                            let isAdmin = item["isSuperAdmin"] as! Int
                            UserDefaults.standard.set(isAdmin == 1 ? true : false, forKey: "isSuperAdmin")
                            self.switchRequestFunction(parameters: parameters, requestID: requestID, list: list, param1: param1)
                
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
            switchRequestFunction(parameters: parameters, requestID: requestID, list: list, param1: param1)
        }

    }
    func switchRequestFunction(parameters: NSDictionary!, requestID: Int, list: [String], param1: NSDictionary!){
        switch (requestID) {

        case LOCKERS_REQUEST:
            self.getLockers(parameters: parameters)
            break
        case CHECK_USERS_REQUEST:
            let userId = parameters[KEY_userId] as! Int
            self.checkUser(userId: userId)
            break
        case TOKEN_REQUEST:
            //Switcher.updateRootVC(isLogged: true)
            let userId = UserDefaults.standard.object(forKey: "userId") as! Int
            self.checkUser(userId: userId)
            break
        case CITIES_REQUEST:
            self.getCities(parameters: parameters)
            break
        case ADDRESSES_REQUEST:
            self.getAddresses(parameters: parameters)
            break
        case INSERT_LOCKER_REQUEST:
            self.postLocker(body: parameters)
            break
        case INSERT_ADDRESS_REQUEST:
            self.postAddress(body: parameters)
            break
        case LOCKER_HISTORY_REQUEST:
            self.getLockerHistory(parameters: parameters, list: list)
            break
        case BUILDING_REQUEST:
            self.getBuilding(parameters: parameters, list: list)
            break
        case BUILDING_RESIDENTS_REQUEST:
            self.getBuildingResidents(parameters: parameters)
            break
        case GET_FILTERED_RESIDENTS_REQUEST:
            self.getFilteredResidents(parameters: parameters)
            break
        case BUILDING_ID_REQUEST:
            self.getBuildingWithId(parameters: parameters)
            break
        case INSERT_LOCKER_BUILDING_RESIDENT_REQUEST:
            self.postLockerBuildingResident(body: parameters)
            break
        case INSERT_LOCKER_HISTORIES_REQUEST:
            self.postLockerHistories(body: parameters)
            break
        case INSERT_NOTIFICATION_REQUEST:
            self.postNotifications(body: parameters)
            break
        case LOCKER_BUILDING_RESIDENT_REQUEST:
            self.getLockerBuildingResident(parameters: parameters)
            break
        case DELETE_LOCKER_BUILDING_RESIDENT_REQUEST:
            self.deleteLockerBuildingResident(parameters: parameters)
            break
        case DELETE_LOCKER_HISTORIES_REQUEST:
            self.deleteLockerHistories(parameters: parameters)
            break
        case GET_BY_FULL_NAME_AND_UNIT_NUMBER:
            self.postGetByFullNameAndUnit(body: parameters, param: param1)
            break
        case INSERT_ORPHAN_PARCEL:
            self.postOrphan(body: parameters)
            break
        case GET_SECURITY_CODE:
            self.getNewSecurityCode()
            break
        
        default:
            print(requestID)
        }
    }
    
    func resetPassword(parameters: NSDictionary, requestID: Int) {
        var urlString: String = getURL()
        urlString.append(contentsOf: usersREST_Action)
        urlString.append(contentsOf: "/")
        urlString.append(contentsOf: resetPasswordRESTAction)
        
        let paramComponent = URLComponents(string: urlString)
       // paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(parameters)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                let message = "Connection error: \(String(describing: response.result.error!)) - \(response.data!)"
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: RESET_PASSWORD_REQUEST)
        }
    }
    
    func deleteLockerHistories(parameters: NSDictionary) {
        var url: String = getURL()
        url.append(contentsOf: lockerHistoryREST_Action)
        if let id = parameters[KEY_id]{
            url.append(contentsOf: "/\(id)")
        }
        let param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        
        Alamofire.request(url, method: .delete, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: DELETE_LOCKER_HISTORIES_REQUEST)
            })
    }
    func deleteLockerBuildingResident(parameters: NSDictionary) {
        var url: String = getURL()
        url.append(contentsOf: lockerBuildingResidentRESTAction)
        if let id = parameters[KEY_id]{
            url.append(contentsOf: "/\(id)")
        }
        let param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
       
        Alamofire.request(url, method: .delete, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: DELETE_LOCKER_BUILDING_RESIDENT_REQUEST)
            })
    }
    func postLocker(body: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: lockersREST_Action)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        print(request.url!)
        print(JSON(request.httpBody!))
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                var message = ""
                if let errorData = response.data {
                    if let json = try? JSON(data: errorData) {
                        message = json["message"].string!
                    }
                } else {
                    message = "Connection error: \(String(describing: response.result.error!))"
                }
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: INSERT_LOCKER_REQUEST)
        }
            
    }
    
    func postOrphan(body: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: orphanParcelRESTAction)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        print(request.url!)
        print(JSON(request.httpBody!))
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                var message = ""
                if let errorData = response.data {
                    if let json = try? JSON(data: errorData) {
                        message = json["message"].string!
                    }
                } else {
                    message = "Connection error: \(String(describing: response.result.error!))"
                }
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: INSERT_ORPHAN_PARCEL)
        }
        
    }
    
    func postAddress(body: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: addressesREST_Action)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                let message = "Connection error: \(String(describing: response.result.error!)) - \(response.data!)"
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: INSERT_ADDRESS_REQUEST)
        }
        
    }
    
    func postLockerBuildingResident(body: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: lockerBuildingResidentRESTAction)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                let message = "Connection error: \(String(describing: response.result.error!)) - \(response.data!)"
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: INSERT_LOCKER_BUILDING_RESIDENT_REQUEST)
        }
        
    }
    
    func postGetByFullNameAndUnit(body: NSDictionary, param: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: residentsRESTAction)
        urlString.append(contentsOf: "/")
        urlString.append(contentsOf: getByFullNameAndUnitNumberAction)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        for (key,value) in param {
            paramComponent?.queryItems?.append(URLQueryItem(name: key as! String, value: "\(value)"))
        }
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            print(bodyJSON.description)
        } catch {
            print("Error \(error)")
        }
        Alamofire.request(request).validate().responseJSON { (response) in
            let url = response.request?.url
            print(url!)
            guard response.result.isSuccess else {
                let message = "Connection error: \(String(describing: response.result.error!)) - \(response.data!)"
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: GET_BY_FULL_NAME_AND_UNIT_NUMBER)
        }
    }
    
    func postLockerHistories(body: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: lockerHistoryREST_Action)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                let message = "Connection error: \(String(describing: response.result.error!)) - \(response.data!)"
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: INSERT_LOCKER_HISTORIES_REQUEST)
        }
        
    }
    func postNotifications(body: NSDictionary){
        var urlString: String = getURL()
        urlString.append(contentsOf: notificationsRESTAction)
        urlString.append(contentsOf: "/")
        urlString.append(contentsOf: sendNotificationToResident)
        
        var paramComponent = URLComponents(string: urlString)
        paramComponent?.queryItems = [URLQueryItem(name: addRest_Token(), value: UserDefaults.standard.object(forKey: "token") as? String)]
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let bodyJSON: JSON = JSON(body)
            request.httpBody = try bodyJSON.rawData()
            //Do something you want
            
        } catch {
            print("Error \(error)")
        }
        print(request.url!)
        print(JSON(request.httpBody!))
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                var message = ""
                if let errorData = response.data {
                    if let json = try? JSON(data: errorData) {
                        message = json["message"].string!
                    }
                } else {
                    message = "Connection error: \(String(describing: response.result.error!))"
                }
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            self.delegate?.resultedData(data: response.data!, requestID: INSERT_NOTIFICATION_REQUEST)
        }
        
    }
    func getLockers(parameters: NSDictionary!){
        var url: String = getURL()
        url.append(contentsOf: lockersREST_Action)
        if let id = parameters[KEY_id]{
           url.append(contentsOf: "/\(id)")
        }
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        if let p = parameters{
            if  let qr = p[KEY_qrCode] {
                param[addREST_Filter(parameters: [KEY_qrCode])] = qr
            }
            if p["expand"] != nil {
                param["expand"] = p["expand"]
            }
        }
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: LOCKERS_REQUEST)
            })
    }
    
    func getNewSecurityCode(){
        var url: String = getURL()
        url.append(contentsOf: residentsRESTAction)
        url.append(contentsOf: "/")
        url.append(contentsOf: getNewSecurityCodeRESTAction)
        
        let param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: GET_SECURITY_CODE)
            })
    }
    
    func getLockerHistory(parameters: NSDictionary!, list: [String]){
        var url: String = getURL()
        url.append(contentsOf: lockerHistoryREST_Action)
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        if let p = parameters{
            param[addREST_Filter(parameters: [KEY_qrCode])] = p[KEY_qrCode]
        }
        if list.count > 0 {
            param[addREST_Filter(parameters: [KEY_buildingUniqueNumber, "in"])] = list
            
        }
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                //let url = response.request?.url?.absoluteString
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: LOCKER_HISTORY_REQUEST)
            })
    }
    
    func getBuildingWithId(parameters: NSDictionary!){
        var url: String = getURL()
        url.append(contentsOf: buildingREST_Action)
        if let buildingId = parameters["id"] {
            url.append(contentsOf: "/\(buildingId)")
        }
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String,
            "sort": KEY_name
        ]
        if let expand = parameters["expand"] {
            param["expand"] = expand
        }
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    print("TREAT")
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: BUILDING_ID_REQUEST)
            })
    }
    
    func getBuilding(parameters: NSDictionary!, list: [String]){
        var url: String = getURL()
        url.append(contentsOf: buildingREST_Action)
        
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String,
            "sort": KEY_name
        ]
        if let expand = parameters["expand"] {
            param["expand"] = expand
        }
        if let p = parameters[KEY_buildingUniqueNumber] {
            param[addREST_Filter(parameters: [KEY_buildingUniqueNumber])] = p
        }
        if let p = parameters[KEY_searchText] {
            param[addREST_Filter(parameters: ["or","",KEY_buildingUniqueNumber,"like"])] = p
            param[addREST_Filter(parameters: ["or","",KEY_name,"like"])] = p
        }
        if let perPage = parameters["per-page"] {
            param["per-page"] = perPage
        }
        if let page = parameters["page"] {
            param["page"] = page
        }
        if list.count > 0 {
            param[addREST_Filter(parameters: [KEY_buildingUniqueNumber, "in"])] = list
        }
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    print("TREAT")
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: BUILDING_REQUEST)
            })
    }
    
    func getBuildingResidents(parameters: NSDictionary!){
        var url: String = getURL()
        url.append(contentsOf: building_ResidentREST_action)
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        if let p = parameters{
            param[addREST_Filter(parameters: [KEY_buildingId])] = p[KEY_buildingId]
        }
        param["sort"] = KEY_buildingId
        param["expand"] = KEY_resident
        
        if let perPage = parameters["per-page"] {
            param["per-page"] = perPage
        }
        if let page = parameters["page"] {
            param["page"] = page
        }
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: BUILDING_RESIDENTS_REQUEST)
            })
    }
    
    func getLockerBuildingResident(parameters: NSDictionary!){
        var url: String = getURL()
        url.append(contentsOf: lockerBuildingResidentRESTAction)
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String
        ]
        
        if let lockerId = parameters[KEY_lockerId] {
            param[addREST_Filter(parameters: [KEY_lockerId])] = lockerId
        }
        if let buildingResidentId = parameters[KEY_buildingResidentId] {
            param[addREST_Filter(parameters: [KEY_buildingResidentId])] = buildingResidentId
        }
        if let securityCode = parameters[KEY_securityCode] {
            param[addREST_Filter(parameters: [KEY_securityCode])] = securityCode
        }
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: LOCKER_BUILDING_RESIDENT_REQUEST)
            })
    }
    
    func getFilteredResidents(parameters: NSDictionary!){
        var url: String = getURL()
        url.append(contentsOf: building_ResidentREST_action)
        url.append(contentsOf: "/")
        url.append(contentsOf: getFilteredResidentRESTAction)
        var param: Parameters = [
            //addREST_Filter(parameters: [qrCodeREST_Key]): qrCode,
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String,
            "sort": KEY_suiteNumber
        ]
        if let p = parameters[KEY_buildingId]{
            param[addREST_Filter(parameters: [KEY_buildingId])] = p
        }
        if let residentName = parameters[KEY_residentName]{
            param[addREST_Filter(parameters: [KEY_residentName])] = residentName
        }
        if let suiteNumber = parameters[KEY_suiteNumber]{
            param[addREST_Filter(parameters: [KEY_suiteNumber])] = suiteNumber
        }
        param["expand"] = KEY_resident
        
        if let perPage = parameters["per-page"] {
            param["per-page"] = perPage
        }
        if let page = parameters["page"] {
            param["page"] = page
        }
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: GET_FILTERED_RESIDENTS_REQUEST)
            })
    }
    
    func checkUser(userId: Int) {
        var url: String = getURL()
        url.append(contentsOf: usersREST_Action)
        url.append(contentsOf: "/\(userId)")
        let param: Parameters = [
            addRest_Token(): UserDefaults.standard.object(forKey: "token") as! String,
            "expand": KEY_userRights+"."+KEY_right+"."+KEY_code+","+KEY_role+","+KEY_buildingXUsers+"."+KEY_building
        ]
        
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                let json = try? JSON(data: response.data!)
                
                UserDefaults.standard.set(json![KEY_firstName].string, forKey: "userFirstName")
                UserDefaults.standard.set(json![KEY_lastName].string, forKey: "userLastName")
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
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: CITIES_REQUEST)
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
                    var message = ""
                    if let errorData = response.data {
                        if let json = try? JSON(data: errorData) {
                            message = json["message"].string!
                        }
                    } else {
                        message = "Connection error: \(String(describing: response.result.error!))"
                    }
                    let statusCode = response.response?.statusCode
                    self.delegate?.treatErrors(statusCode, errorMessage: message)
                    return
                }
                self.delegate?.resultedData(data: response.data!, requestID: ADDRESSES_REQUEST)
            })
    }
}
