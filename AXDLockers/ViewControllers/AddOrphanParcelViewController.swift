//
//  AddOrphanParcelViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 24/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import SwiftyJSON

class AddOrphanParcelViewController: UIViewController, UITextViewDelegate, RestRequestsDelegate {
    
    

    @IBOutlet weak var parcelDescriptionTextView: UITextView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var line1: String!
    var line2: String!
    var line3Address: String!
    var line4Street: String!
    let restRequest = RestRequests()
    var orphanParcel: OrphanParcelModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentsTextView.delegate = self
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        parcelDescriptionTextView.layer.cornerRadius = 10
        commentsTextView.layer.cornerRadius = 10
        restRequest.delegate = self
        activityIndicator.stopAnimating()
        var parcelDescription: String = ""
        if let _ = line1 {
            parcelDescription = line1
        }
        parcelDescription += "\n"
        
        if let _ = line4Street {
            parcelDescription += line4Street
        }
        parcelDescription += " - "
        if let _ = line2 {
            parcelDescription += "Unit # " + line2
        }
        parcelDescription += "\n"
        if let _ = line3Address {
            parcelDescription += line3Address
        }
        parcelDescriptionTextView.text = parcelDescription.trimmingCharacters(in: CharacterSet("\n".unicodeScalars)).trimmingCharacters(in: CharacterSet(" - ".unicodeScalars))
        
        if let userId = UserDefaults.standard.object(forKey: "userId") as? Int {
            activityIndicator.startAnimating()
            let param = [KEY_userId: userId] as NSDictionary
            restRequest.checkForRequest(parameters: param, requestID: CHECK_USERS_REQUEST)
        } else {
            Switcher.updateRootVC(isLogged: false)
        }
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
         animateViewMoving(up: true, moveValue: 100)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: 100)
    }
    
    @IBAction func tapOnAdd(_ sender: Any) {
        postOrphanParcel()
    }
    
    func postOrphanParcel (){
        guard parcelDescriptionTextView.text != "" else {return}
        activityIndicator.startAnimating()
        var param:[String: Any] = [:]
        param["parcelDescription"] = parcelDescriptionTextView.text
        if commentsTextView.text != "" {
            param["comments"] = commentsTextView.text
        }
        restRequest.checkForRequest(parameters: param as NSDictionary, requestID: INSERT_ORPHAN_PARCEL)
       
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showSummary", let destination = segue.destination as? SummaryOrphanViewController {
            destination.oprhanParcel = orphanParcel
        }
    }
   
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func userHaveRight(rights: JSON, code: String) -> Bool {
        for (_, right) in rights {
            if right[KEY_right][KEY_code].string == code {
                return true
            }
        }
        return false
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        activityIndicator.stopAnimating()
    }
    
    func resultedData(data: Data!, requestID: Int) {
        activityIndicator.stopAnimating()
        let json = try? JSON(data: data)
        if requestID == CHECK_USERS_REQUEST {
            let userXRights: JSON = getJSON(json: json, desiredKey: KEY_userRights)
            
            addButton.isEnabled = userHaveRight(rights: userXRights, code: "CREATE_PACKAGES")
            if !addButton.isEnabled {
                let alertController = UIAlertController(title: "No proper right", message: "You don't have right to add unknown parcels. Contact adimistrator.", preferredStyle: UIAlertController.Style.alert)
                let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alertController.addAction(okBut)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        if requestID == INSERT_ORPHAN_PARCEL {
            let createdAt = json!["createdAt"].double
            let parcelDescription = json!["parcelDescription"].string
            var comments: String!
            if json!["comments"].type != .null {
                comments = json!["comments"].string
            }
            orphanParcel = OrphanParcelModel(parcelDescriptions: parcelDescription!, id: json!["id"].int!, createdAt: createdAt!, comments: comments)
            
            performSegue(withIdentifier: "showSummary", sender: nil)
        }
    }
}
