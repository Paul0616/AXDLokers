//
//  Address.swift
//  AXDLockers
//
//  Created by Paul Oprea on 27/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Address: NSObject, NSCoding {
    var street: String
    var cityName: String
    var stateName: String
    var zipCode: String
    var id: Int
    //MARK: - Initializare
    
    init(street: String,
          id: Int, cityName: String, stateName: String, zipCode: String
        ) {
        
        //Initializeaza proprietatile
        self.street = street
        self.id = id
        self.cityName = cityName
        self.stateName = stateName
        self.zipCode = zipCode
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let street = aDecoder.decodeObject(forKey: "street") as! String
        let cityName = aDecoder.decodeObject(forKey: "cityName") as! String
        let stateName = aDecoder.decodeObject(forKey: "stateName") as! String
        let zipCode = aDecoder.decodeObject(forKey: "zipCode") as! String
        self.init(street: street, id: id, cityName: cityName, stateName: stateName, zipCode: zipCode)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(street, forKey: "street")
        aCoder.encode(cityName, forKey: "cityName")
        aCoder.encode(stateName, forKey: "stateName")
        aCoder.encode(zipCode, forKey: "zipCode")
    }
}
