//
//  Resident.swift
//  AXDLockers
//
//  Created by Paul Oprea on 28/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Resident: NSObject, NSCoding {
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var securityCode: String
    var suiteNumber: String
    var id: Int
    var buildingResidentId: Int
    var building: Building!
    //MARK: - Initializare
    
    init(id: Int, firstName: String, lastName: String, phone: String, email: String, securityCode: String, suiteNumber: String, buildingResidentId: Int
        ) {
        
        //Initializeaza proprietatile
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.phone = phone
        self.email = email
        self.securityCode = securityCode
        self.suiteNumber = suiteNumber
        self.buildingResidentId = buildingResidentId
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let firstName = aDecoder.decodeObject(forKey: "firstName") as! String
        let lastName = aDecoder.decodeObject(forKey: "lastName") as! String
        let phone = aDecoder.decodeObject(forKey: "phone") as! String
        let email = aDecoder.decodeObject(forKey: "email") as! String
        let securityCode = aDecoder.decodeObject(forKey: "securityCode") as! String
        let suiteNumber = aDecoder.decodeObject(forKey: "suiteNumber") as! String
        let buildingResidentId = aDecoder.decodeObject(forKey: "buildingResidentId") as! Int
        self.init(id: id, firstName: firstName, lastName: lastName, phone: phone, email: email, securityCode: securityCode, suiteNumber: suiteNumber, buildingResidentId: buildingResidentId)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(securityCode, forKey: "securityCode")
        aCoder.encode(suiteNumber, forKey: "suiteNumber")
        aCoder.encode(buildingResidentId, forKey: "buildingResidentId")
    }
}
