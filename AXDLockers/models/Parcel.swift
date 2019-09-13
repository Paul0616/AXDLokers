//
//  Parcel.swift
//  AXDLockers
//
//  Created by Paul Oprea on 12/09/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class Parcel: NSObject, NSCoding {
    var id: Int
    var lockerId: Int
    var buildingResidentId: Int
    var securityCode: String
    var status: Int
    var buildingResident: BuildingXResident
    var building: Building
    

    //MARK: - Initializare
    init(id: Int, lockerId: Int, buildingResidentId: Int, securityCode: String, status: Int, buildingResident: BuildingXResident, building: Building
        ) {
        //Initializeaza proprietatile
        self.id = id
        self.lockerId = lockerId
        self.buildingResidentId = buildingResidentId
        self.securityCode = securityCode
        self.status = status
        self.buildingResident = buildingResident
        self.building = building
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let lockerId = aDecoder.decodeInteger(forKey: "lockerId")
        let buildingResidentId = aDecoder.decodeInteger(forKey: "buildingResidentId")
        let securityCode = aDecoder.decodeObject(forKey: "securityCode") as! String
        let status = aDecoder.decodeInteger(forKey: "status")
        let buildingResident = aDecoder.decodeObject(forKey: "buildingResident") as! BuildingXResident
        let building = aDecoder.decodeObject(forKey: "building") as! Building
        self.init(id: id, lockerId: lockerId, buildingResidentId: buildingResidentId, securityCode: securityCode, status: status, buildingResident: buildingResident, building: building)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(lockerId, forKey: "lockerId")
        aCoder.encode(buildingResidentId, forKey: "buildingResidentId")
        aCoder.encode(securityCode, forKey: "securityCode")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(buildingResident, forKey: "buildingResident")
        aCoder.encode(building, forKey: "building")
    }
}
