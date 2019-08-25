//
//  OrphanParcelModel.swift
//  AXDLockers
//
//  Created by Paul Oprea on 24/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class OrphanParcelModel: NSObject, NSCoding {
    var id: Int
    var parcelDescriptions: String
    var comments: String!
    var createdAt: Double
    
    //MARK: - Initializare
    
    init(parcelDescriptions: String,
         id: Int, createdAt: Double, comments: String!
        ) {
        
        //Initializeaza proprietatile
        self.parcelDescriptions = parcelDescriptions
        self.id = id
        self.createdAt = createdAt
        self.comments = comments
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeInteger(forKey: "id")
        let parcelDescriptions = aDecoder.decodeObject(forKey: "parcelDescriptions") as! String
        let createdAt = aDecoder.decodeDouble(forKey: "createdAt")
        let comments = aDecoder.decodeObject(forKey: "comments") as! String
        
        self.init(parcelDescriptions: parcelDescriptions, id: id, createdAt: createdAt, comments: comments)
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(parcelDescriptions, forKey: "parcelDescriptions")
        aCoder.encode(comments, forKey: "comments")
    }
}

