//
//  Address.swift
//  AXDLockers
//
//  Created by Paul Oprea on 27/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Address: NSObject {
    var street: String
    var cityName: String
    var stateName: String
    var zipCode: String
    var id: Int
    //MARK: - Initializare
    
    init?(street: String,
          id: Int, cityName: String, stateName: String, zipCode: String
        ) {
        
        //Initializeaza proprietatile
        self.street = street
        self.id = id
        self.cityName = cityName
        self.stateName = stateName
        self.zipCode = zipCode
    }
}
