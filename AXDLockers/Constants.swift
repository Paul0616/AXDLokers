//
//  Constants.swift
//  AXDLockers
//
//  Created by Paul Oprea on 21/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CommonCrypto

let scheme: String = "http"
let baseURL: String = "lockers.ondesign.ro"
let port: String = ""
let urlFolders: [String] = ["v1"]

//REST Control Actions
let tokensREST_Action = "tokens"
let usersREST_Action = "users"
let emailREST_Action = "email"
let passwordREST_Action = "password"

func getURL() -> String {
    var url: String = ""
    url.append(contentsOf: scheme)
    url.append(contentsOf: "://")
    url.append(contentsOf: baseURL)
    if !port.elementsEqual("") {
        url.append(contentsOf: ":")
        url.append(contentsOf: port)
    }
    for urlFolder in urlFolders {
        url.append(contentsOf: "/")
        url.append(contentsOf: urlFolder)
    }
    url.append(contentsOf: "/")
    return url
}
func addREST_Filter(parameters: [String]) -> String {
    var filterString: String = "filter"
    for parameter in parameters {
        filterString.append(contentsOf: "[")
        filterString.append(contentsOf: parameter)
        filterString.append(contentsOf: "]")
    }
    return filterString
}
func encryptPassword(password: String) -> String {
    
    var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
    if let data = password.data(using: String.Encoding.utf8) {
        let value =  data as NSData
        CC_SHA512(value.bytes, CC_LONG(data.count), &digest)
        
    }
    var digestHex = ""
    for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
        digestHex += String(format: "%02x", digest[index])
    }
    
    return digestHex
}

func getItems(json: NSDictionary) -> NSArray! {
    //var items: NSDictionary
    let items = json["items"] as! NSArray
    return items
}

