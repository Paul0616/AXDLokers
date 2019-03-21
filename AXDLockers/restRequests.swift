//
//  restRequests.swift
//  AXDLockers
//
//  Created by Paul Oprea on 21/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import Alamofire

class restRequests: NSObject {
    func getNewToken(userEmail: String, encryptedPassword: String){
        var token: String = ""
        var url: String = getURL()
        url.append(contentsOf: tokensREST_Action)
        let param: Parameters = [
            addREST_Filter(parameters: [emailREST_Action]): userEmail,
            addREST_Filter(parameters: [passwordREST_Action]): encryptedPassword
        ]
        //    url.append(contentsOf: addREST_Filter(parameters: [emailREST_Action], value: userEmail))
        //    url.append(contentsOf: "&")
        //    url.append(contentsOf: addREST_Filter(parameters: [passwordREST_Action], value: encryptedPassword))
        Alamofire.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON(completionHandler: {response in
                guard response.result.isSuccess else {
                    print("Error while fetching token: \(String(describing: response.result.error))")
                    let statusCode = response.response?.statusCode
                    switch statusCode {
                    case 404:
                        print("User does not exist or User email/password is not correct")
                    case .none:
                        print("none")
                    case .some(_):
                        print(statusCode!)
                    }
                    //                    //completion(nil)
                    return
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                    
                    //print(json)
                    if let items = getItems(json: json) {
                        print(items)
                    }
                }  catch let error as NSError
                {
                    print(error.localizedDescription)
                }
            })
    }
}
