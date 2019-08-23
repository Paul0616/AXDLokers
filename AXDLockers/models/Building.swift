//
//  Building.swift
//  AXDLockers
//
//  Created by Paul Oprea on 29/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Building: NSObject, NSCoding {
    var name: String
    var address: String
    var street: String!
    var buidingUniqueNumber: String
    var id: Int
    //MARK: - Initializare
    
    init(id: Int, name: String, address: String, buidingUniqueNumber: String
        ) {
        //Initializeaza proprietatile
        self.name = name
        self.id = id
        self.address = address
        self.buidingUniqueNumber = buidingUniqueNumber
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let address = aDecoder.decodeObject(forKey: "address") as! String
        let buidingUniqueNumber = aDecoder.decodeObject(forKey: "buidingUniqueNumber") as! String
        
        self.init(id: id, name: name, address: address, buidingUniqueNumber: buidingUniqueNumber)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "address")
        aCoder.encode(buidingUniqueNumber, forKey: "buidingUniqueNumber")
        
    }
}
