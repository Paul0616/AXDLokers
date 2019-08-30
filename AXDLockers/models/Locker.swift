//
//  Locker.swift
//  AXDLockers
//
//  Created by Paul Oprea on 30/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Locker: NSObject, NSCoding {
    var id: Int
    var qrCode: String
    var size: String
    var number: String
    var address: Address
    //MARK: - Initializare
    init(id: Int, qrCode: String, number: String, size: String, address: Address
        ) {
        //Initializeaza proprietatile
        self.id = id
        self.qrCode = qrCode
        self.size = size
        self.number = number
        self.address = address
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let qrCode = aDecoder.decodeObject(forKey: "qrCode") as! String
        let size = aDecoder.decodeObject(forKey: "size") as! String
        let number = aDecoder.decodeObject(forKey: "number") as! String
        let address = aDecoder.decodeObject(forKey: "address") as! Address
        self.init(id: id, qrCode: qrCode, number: number, size: size, address: address)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(qrCode, forKey: "qrCode")
        aCoder.encode(size, forKey: "size")
        aCoder.encode(number, forKey: "number")
        aCoder.encode(address, forKey: "address")
    }
}
