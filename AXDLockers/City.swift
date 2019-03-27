//
//  City.swift
//  AXDLockers
//
//  Created by Paul Oprea on 26/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class City: NSObject {
    var name: String
    var id: Int
    //MARK: - Initializare
    
    init?(name: String,
          id: Int
        ) {
        
        //Initializeaza proprietatile
        self.name = name
        self.id = id
    }
}
