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
    var savedParameters: Parameters!
    var savedBody: NSDictionary!
    override init() {
        //init
    }
    
    func checkForRequest(parameters: Parameters!, requestID: Int, body: NSDictionary! = nil){
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
            savedParameters = parameters
            savedBody = body
            if let userEmail = UserDefaults.standard.object(forKey: "userEmail") as? String, let encryptedPassword = UserDefaults.standard.object(forKey: "encryptedPassword") as? String {
                print("\nGET NEW TOKEN")
                let param = [
                    addREST_Filter(parameters: [KEY_userEmail]): userEmail,
                    addREST_Filter(parameters: [KEY_password]): encryptedPassword
                ] as Parameters
                callHandler(
                    urlStrings: [tokensREST_Action],
                    method: "GET",
                    useAuthentication: false,
                    isGetToken: true,
                    additionalQueryItems: param,
                    body: nil,
                    requestId: requestID)
            } else {
                if requestID == RESET_PASSWORD_REQUEST{
                    switchRequestFunction(parameters: parameters, requestID: requestID, body: body)
                } else {
                    print("userEmail or encryptedPassword in not set")
                    Switcher.updateRootVC(isLogged: false)
                }
            }
        }
        else {
            savedBody = nil
            savedParameters = nil
            switchRequestFunction(parameters: parameters, requestID: requestID, body: body)
        }

    }
    func switchRequestFunction(parameters: Parameters!, requestID: Int, body: NSDictionary!){
        switch (requestID) {

        case LOCKERS_REQUEST:
            print("LOCKERS_REQUEST")
            callHandler(
                urlStrings: [lockersREST_Action],
                method: "GET",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: parameters,
                body: nil,
                requestId: requestID
            )
            break
        case CHECK_USERS_REQUEST:
             print("CHECK_USERS_REQUEST")
            if let userId = UserDefaults.standard.object(forKey: "userId") as? Int {
                let extraParam = [ "expand":KEY_userRights+"."+KEY_right+"."+KEY_code+","+KEY_role+","+KEY_buildingXUsers+"."+KEY_building
                    ] as Parameters
                callHandler(
                    urlStrings: [usersREST_Action, "\(userId)"],
                    method: "GET",
                    useAuthentication: true,
                    isGetToken: false,
                    additionalQueryItems: extraParam,
                    body: nil,
                    requestId: requestID
                )
            }
            break
        case CITIES_REQUEST:
            print("CITIES_REQUEST")
            callHandler(
                urlStrings: [citiesREST_Action],
                method: "GET",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: parameters,
                body: nil,
                requestId: requestID
            )
            break
        case ADDRESSES_REQUEST:
             print("ADDRESSES_REQUEST")
            callHandler(
                urlStrings: [addressesREST_Action],
                method: "GET",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: parameters,
                body: nil,
                requestId: requestID
            )
            break
        case INSERT_LOCKER_REQUEST:
             print("INSERT_LOCKER_REQUEST")
            callHandler(
                urlStrings: [lockersREST_Action],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        case INSERT_ADDRESS_REQUEST:
             print("INSERT_ADDRESS_REQUEST")
            callHandler(
                urlStrings: [addressesREST_Action],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        case INSERT_LOCKER_BUILDING_RESIDENT_REQUEST:
             print("INSERT_LOCKER_BUILDING_RESIDENT_REQUEST")
            callHandler(
                urlStrings: [lockerBuildingResidentRESTAction],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        case INSERT_LOCKER_HISTORIES_REQUEST:
             print("INSERT_LOCKER_HISTORIES_REQUEST")
            callHandler(
                urlStrings: [lockerHistoryREST_Action],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        case INSERT_NOTIFICATION_REQUEST:
             print("INSERT_NOTIFICATION_REQUEST")
            callHandler(
                urlStrings: [notificationsRESTAction, sendNotificationToResident],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        case LOCKER_BUILDING_RESIDENT_REQUEST:
             print("LOCKER_BUILDING_RESIDENT_REQUEST")
            callHandler(
                urlStrings: [lockerBuildingResidentRESTAction],
                method: "GET",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: parameters,
                body: nil,
                requestId: requestID
            )
            break
        case DELETE_VIRTUAL_PARCEL_REQUEST:
            print("DELETE_VIRTUAL_PARCEL_REQUEST")
            let id = parameters[KEY_id] as! Int
            callHandler(
                urlStrings: [virtualParcelRESTAction, "\(id)"],
                method: "DELETE",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: nil,
                requestId: requestID
            )
            break
        case DELETE_LOCKER_BUILDING_RESIDENT_REQUEST:
             print("DELETE_LOCKER_BUILDING_RESIDENT_REQUEST")
            let id = parameters[KEY_id] as! Int
            callHandler(
                urlStrings: [lockerBuildingResidentRESTAction, "\(id)"],
                method: "DELETE",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: nil,
                requestId: requestID
            )
            break
        case DELETE_LOCKER_HISTORIES_REQUEST:
             print("DELETE_LOCKER_HISTORIES_REQUEST")
            let id = parameters[KEY_id] as! Int
            callHandler(
                urlStrings: [lockerHistoryREST_Action, "\(id)"],
                method: "DELETE",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: nil,
                requestId: requestID
            )
            break
        case GET_BY_FULL_NAME_AND_UNIT_NUMBER:
             print("GET_BY_FULL_NAME_AND_UNIT_NUMBER")
            callHandler(
                urlStrings: [residentsRESTAction, getByFullNameAndUnitNumberAction],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: parameters,
                body: body,
                requestId: requestID
            )
            break
        case INSERT_ORPHAN_PARCEL:
             print("INSERT_ORPHAN_PARCEL")
            callHandler(
                urlStrings: [orphanParcelRESTAction],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        case GET_SECURITY_CODE:
             print("GET_SECURITY_CODE")
            callHandler(
                urlStrings: [residentsRESTAction, getNewSecurityCodeRESTAction],
                method: "GET",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: nil,
                requestId: requestID
            )
            break
        case INSERT_VIRTUAL_PARCEL_REQUEST:
             print("INSERT_VIRTUAL_PARCEL_REQUEST")
            callHandler(
                urlStrings: [virtualParcelRESTAction],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
        case INSERT_NOTIFICATION_FOR_VIRTUAL_PARCEL_REQUEST:
         print("INSERT_NOTIFICATION_FOR_VIRTUAL_PARCEL_REQUEST")
            callHandler(
                urlStrings: [notificationsRESTAction, sendNotificationToResidentForVirtualParcelRESTAction],
                method: "POST",
                useAuthentication: true,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
        case RESET_PASSWORD_REQUEST:
            print("RESET_PASSWORD_REQUEST")
            callHandler(
                urlStrings: [usersREST_Action, resetPasswordRESTAction],
                method: "PUT",
                useAuthentication: false,
                isGetToken: false,
                additionalQueryItems: nil,
                body: body,
                requestId: requestID
            )
            break
        default:
            print("\nRequestId=\(requestID)")
        }
    }
    
    func callHandler(urlStrings: [String], method: String?, useAuthentication: Bool, isGetToken: Bool, additionalQueryItems: Parameters!, body: NSDictionary!, requestId: Int){
        var urlString: String = getURL()
        urlString.append(urlStrings.joined(separator: "/"))
        
        var paramComponent = URLComponents(string: urlString)
        var queryItems:[URLQueryItem] = [URLQueryItem]()
        if useAuthentication {
            let queryItem = URLQueryItem(
                name: addRest_Token(),
                value: UserDefaults.standard.object(forKey: "token") as? String
            )
            queryItems.append(queryItem)
        }
        if let param = additionalQueryItems {
            for (key,value) in param {
                queryItems.append(URLQueryItem(name: key , value: "\(value)"))
            }
        }
        if queryItems.count > 0 {
            paramComponent?.queryItems = queryItems
        }
        
        var request = URLRequest(url: paramComponent!.url!)
        request.httpMethod = method
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let bodyJSON: JSON = JSON(body)
                request.httpBody = try bodyJSON.rawData()
            } catch {
                print("Error \(error)")
            }
            print("Body: \(JSON(request.httpBody!))")
        }
        print("\(request.url!)\n")
        
        Alamofire.request(request).validate().responseJSON { (response) in
            guard response.result.isSuccess else {
                var message = ""
                if let errorData = response.data {
                    if let json = try? JSON(data: errorData) {
                        if json.type == .array{
                            message = json[0]["message"].string!
                        } else {
                            message = json["message"].string!
                        }
                    }
                } else {
                    message = "Connection error: \(String(describing: response.result.error!))"
                }
                let statusCode = response.response?.statusCode
                self.delegate?.treatErrors(statusCode, errorMessage: message)
                return
            }
            if !isGetToken {
                self.delegate?.resultedData(data: response.data!, requestID: requestId)
            } else {
                let json = try? JSON(data: response.data!)
                if let items: JSON = getJSON(json: json, desiredKey: KEY_items){
                    
                    UserDefaults.standard.set(items[0]["accessToken"].string, forKey: "token")
                    UserDefaults.standard.set(items[0]["tokenExpiresAt"].double , forKey: "tokenExpiresAt")
                    UserDefaults.standard.set(items[0]["id"].int, forKey: "userId")
                    let isAdmin = items[0]["isSuperAdmin"].int
                    UserDefaults.standard.set(isAdmin == 1 ? true : false, forKey: "isSuperAdmin")
                    self.switchRequestFunction(parameters: self.savedParameters, requestID: requestId, body: self.savedBody)
                }
                
            }
        }
    }

  
}
