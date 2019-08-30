//
//  Locker.swift
//  AXDLockers
//
//  Created by Paul Oprea on 31/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class LockerHistory: NSObject {
//    var qrCode: String
//    var number: String
//    var size: String
//    var lockerAddress: String
    var locker: Locker
    
    
//    var firstName: String
//    var lastName:String
//    var email: String
//    var phoneNumber: String!
    var securityCode: String!
//    var residentAddress: String
//    var suiteNumber: String
//    var buildingUniqueNumber: String
//    var name: String
//    var buildingAddress: String
    
    var resident: Resident
    
    //MARK: - Initializare
    init(locker: Locker, resident: Resident){
        self.locker = locker
        self.resident = resident
    }
//    init(qrCode: String, lockerAddress: String, number: String, size: String, firstName: String, lastName: String, email: String, phoneNumber: String!, residentAddress: String, suiteNumber: String, buildingUniqueNumber: String, name: String, buildingAddress: String
//        ) {
//        //Initializeaza proprietatile
//        self.qrCode = qrCode
//        self.size = size
//        self.lockerAddress = lockerAddress
//        self.number = number
//        self.firstName = firstName
//        self.lastName = lastName
//        self.email = email
//        self.phoneNumber = phoneNumber
//        self.residentAddress = residentAddress
//        self.suiteNumber = suiteNumber
//        self.buildingUniqueNumber = buildingUniqueNumber
//        self.name = name
//        self.buildingAddress = buildingAddress
//
//    }
    
}
