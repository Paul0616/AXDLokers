//
//  Resident.swift
//  AXDLockers
//
//  Created by Paul Oprea on 28/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Resident: NSObject, NSCoding {
    var name: String
    var phone: String
    var email: String
    var securityCode: String
    var suiteNumber: String
    var id: Int
    //MARK: - Initializare
    
    init(id: Int, name: String, phone: String, email: String, securityCode: String, suiteNumber: String
        ) {
        
        //Initializeaza proprietatile
        self.name = name
        self.id = id
        self.phone = phone
        self.email = email
        self.securityCode = securityCode
        self.suiteNumber = suiteNumber
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let phone = aDecoder.decodeObject(forKey: "phone") as! String
        let email = aDecoder.decodeObject(forKey: "email") as! String
        let securityCode = aDecoder.decodeObject(forKey: "securityCode") as! String
        let suiteNumber = aDecoder.decodeObject(forKey: "suiteNumber") as! String
        self.init(id: id, name: name, phone: phone, email: email, securityCode: securityCode, suiteNumber: suiteNumber)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(securityCode, forKey: "securityCode")
        aCoder.encode(suiteNumber, forKey: "suiteNumber")
    }
}
