//
//  Constants.swift
//  AXDLockers
//
//  Created by Paul Oprea on 21/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import Foundation
import SwiftyJSON
import CommonCrypto

let scheme: String = "https"
let baseURL: String = "lockers.ondesign.ro" //"admin.smartlockers.ca"
let port: String = ""
let urlFolders: [String] = ["v1"]



//REST Control Actions
let tokensREST_Action = "tokens"
let usersREST_Action = "users"
let lockersREST_Action = "lockers"
let citiesREST_Action = "cities"
let addressesREST_Action = "addresses"
let lockerHistoryREST_Action = "locker-histories"
let buildingREST_Action = "buildings"
let building_ResidentREST_action = "building-residents"
let residentsRESTAction = "residents"
let getFilteredResidentRESTAction = "get-filtered-residents"
let lockerBuildingResidentRESTAction = "locker-building-residents"
let notificationsRESTAction = "notifications"
let sendNotificationToResident = "send-notification-to-resident"
let resetPasswordRESTAction = "reset-password"

//REST Keys
let KEY_userEmail = "email"
let KEY_password = "password"
let KEY_qrCode = "qrCode"
let KEY_userId = "userId"
let KEY_role = "role"
let KEY_hasRelatedBuildings = "hasRelatedBuildings"
let KEY_buildingXUsers = "buildingXUsers"
let KEY_state = "state"
let KEY_name = "name"
let KEY_items = "items"
let KEY_meta = "_meta"
let KEY_links = "_links"
let KEY_id = "id"
let KEY_streetName = "streetName"
let KEY_city = "city"
let KEY_cityId = "cityId"
let KEY_zipCode = "zipCode"
let KEY_number = "number"
let KEY_size = "size"
let KEY_addressId = "addressId"
let KEY_address = "address"
let KEY_buildingUniqueNumber = "buildingUniqueNumber"
let KEY_buildingAddress = "buildingAddress"
let KEY_buildingXResidents = "buildingXResidents"
let KEY_building = "building"
let KEY_buildingId = "buildingId"
let KEY_resident = "resident"
let KEY_suiteNumber = "suiteNumber"
let KEY_residentName = "residentName"
let KEY_firstName = "firstName"
let KEY_lastName = "lastName"
let KEY_email = "email"
let KEY_phone = "phoneNumber"
let KEY_securityCode = "securityCode"
let KEY_searchText = "searchText"
let KEY_lockerId = "lockerId"
let KEY_lockerAddress = "lockerAddress"
let KEY_buildingResidentId = "buildingResidentId"
let KEY_lockerBuildingResidentId = "lockerBuildingResidentId"
let KEY_status = "status"
let KEY_userRights = "userXRights"
let KEY_right = "right"
let KEY_code = "code"
//requests IDs
let LOCKERS_REQUEST = 1
let CHECK_USERS_REQUEST = 2
let TOKEN_REQUEST = 3
let CITIES_REQUEST = 4
let ADDRESSES_REQUEST = 5
let INSERT_LOCKER_REQUEST = 6
let INSERT_ADDRESS_REQUEST = 7
let LOCKER_HISTORY_REQUEST = 8
let BUILDING_REQUEST = 9
let BUILDING_RESIDENTS_REQUEST = 10
let GET_FILTERED_RESIDENTS_REQUEST = 11
let BUILDING_ID_REQUEST = 12
let INSERT_LOCKER_BUILDING_RESIDENT_REQUEST = 13
let INSERT_LOCKER_HISTORIES_REQUEST = 14
let INSERT_NOTIFICATION_REQUEST = 15
let LOCKER_BUILDING_RESIDENT_REQUEST = 16
let DELETE_LOCKER_BUILDING_RESIDENT_REQUEST = 17
let DELETE_LOCKER_HISTORIES_REQUEST = 18
let RESET_PASSWORD_REQUEST = 19

let STATUS_NOT_CONFIRMED = 1

func getURL() -> String {
    var url: String = ""
    url.append(contentsOf: scheme)
    url.append(contentsOf: "://")
    url.append(contentsOf: baseURL)
    if !port.elementsEqual("") {
        url.append(contentsOf: ":")
        url.append(contentsOf: port)
    }
    for urlFolder in urlFolders {
        url.append(contentsOf: "/")
        url.append(contentsOf: urlFolder)
    }
    url.append(contentsOf: "/")
    return url
}
func addREST_Filter(parameters: [String]) -> String {
    var filterString: String = "filter"
    for parameter in parameters {
        filterString.append(contentsOf: "[")
        filterString.append(contentsOf: parameter)
        filterString.append(contentsOf: "]")
    }
    return filterString
}
func addRest_Token() -> String {
    let tokenString: String = "access-token"
    return tokenString
}
func encryptPassword(password: String) -> String {
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
    if let data = password.data(using: String.Encoding.utf8) {
        let value =  data as NSData
        CC_SHA512(value.bytes, CC_LONG(data.count), &digest)
        
    }
    var digestHex = ""
    for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
        digestHex += String(format: "%02x", digest[index])
    }
    
    return digestHex
}


func getJSON(json: JSON!, desiredKey: String) -> JSON! {
    var items:JSON!
    for (key, value) in json! {
        if key == desiredKey {
            items = value
            break
        }
    }
    return items
}

func isLastPageLoaded(json: JSON!) -> Bool {
    //var items: NSDictionary
    var lastPage:Bool = true
    for (key, value) in json! {
        if key == KEY_links {
            if value["next"].count > 0 {
                lastPage = false
            }
            break
        }
    }
    return lastPage
}

func setupCloseButton(viewController: UIViewController) -> UIButton {
    let closeButton = UIButton()
    viewController.view.addSubview(closeButton)
    
    // Stylistic features.
    closeButton.setTitle("✕", for: .normal)
    closeButton.setTitleColor(UIColor.white, for: .normal)
    closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    
//    // Add a target function when the button is tapped.
//    closeButton.addTarget(viewController, action: #selector(closeAction), for: .touchDown)
    
    // Constrain the button to be positioned in the top left corner (with some offset).
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20).isActive = true
    closeButton.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 20).isActive = true
    return closeButton
}


