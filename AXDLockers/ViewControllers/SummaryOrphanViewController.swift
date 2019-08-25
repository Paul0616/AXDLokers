//
//  SummaryOrphanViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 24/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class SummaryOrphanViewController: UIViewController {
    @IBOutlet weak var summaryTitleLabel: UILabel!
    @IBOutlet weak var parcelDescriptionLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    var oprhanParcel: OrphanParcelModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let orphanParcel = oprhanParcel {
            let date = Date(timeIntervalSince1970: orphanParcel.createdAt)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            //dateFormatter.dateFormat = "dd/MM/YYYY HH:mm"
            
            dateFormatter.locale = Locale(identifier: "en_US")
            let d = dateFormatter.string(from: date)
            summaryTitleLabel.text = "You just added at\n\(d)\nan unknown parcel with specifications:"
            parcelDescriptionLabel.text = orphanParcel.parcelDescriptions
            if let comments = orphanParcel.comments {
                commentsLabel.text = comments
            } else {
                 commentsLabel.text = ""
            }
        } else {
            summaryTitleLabel.text = ""
            parcelDescriptionLabel.text = ""
            commentsLabel.text = ""
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
