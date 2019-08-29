//
//  ViewController.swift
//  AXDLokers
//
//  Created by Paul Oprea on 18/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON


class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, RestRequestsDelegate {
    
    
    
    @IBOutlet weak var messageLabel: UILabel!
   
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var codeWasdetected: Bool = false
    
    let restRequests = RestRequests()
    var qrCode: String!
    var resident: Resident!
    var lockerId: Int!
    var lockerHistory: LockerHistory!
    var userCanCreateLockers: Bool = false
    var userCanViewAddresses: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        restRequests.delegate = self
//        if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in })
//        }
        var captureDevice: AVCaptureDevice!
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
            captureDevice = device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            captureDevice = device
        } else {
            return
        }
        
    
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
//        print(deviceDiscoverySession.devices.count)
//
//        guard let captureDevice = deviceDiscoverySession.devices.first else {
//            print("Failed to get the camera device")
//            return
//        }
        //messageFrame.layer.cornerRadius = 6

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill//AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds //cameraContainer.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!) //view
        
        // Start video capture.
        captureSession.startRunning()
       
        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
     
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView) //view
            view.bringSubviewToFront(qrCodeFrameView) //view
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        if let code = UserDefaults.standard.object(forKey: "codeWasdetected") as? Bool {
            codeWasdetected = code
            print("TRUE")
        } else {
            codeWasdetected = false
        }
    }
//    override func viewDidDisappear(_ animated: Bool) {
//        codeWasdetected = false
//    }
    
    
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        if requestID == LOCKERS_REQUEST {
            let items: JSON = getJSON(json: json, desiredKey: KEY_items)
            print(items.count)
            if items.count > 0 && codeWasdetected {
                let locker = items[0]
                lockerId = locker[KEY_id].int!
            
                print("item found - \(lockerId!)")
                let lockerAddress = Address(street: locker[KEY_address][KEY_streetName].string!, id: locker[KEY_address][KEY_id].int!, cityName: locker[KEY_address][KEY_city][KEY_name].string!, stateName: locker[KEY_address][KEY_city][KEY_state][KEY_name].string!, zipCode: locker[KEY_address][KEY_zipCode].string!)
                let lockerAddressArray = [lockerAddress.street, lockerAddress.cityName, lockerAddress.stateName, lockerAddress.zipCode]
                lockerHistory = LockerHistory(qrCode: qrCode, lockerAddress: lockerAddressArray.joined(separator: ", "), number: locker[KEY_number].string!, size: locker[KEY_size].string!, firstName: resident.firstName, lastName: resident.lastName, email: resident.email, phoneNumber: resident.phone, securityCode: resident.securityCode, residentAddress: resident.building.address, suiteNumber: resident.suiteNumber, buildingUniqueNumber: resident.building.buidingUniqueNumber, name: resident.building.name, buildingAddress: resident.building.address)
                //self.performSegue(withIdentifier: "existingLockerToResidentsSegue", sender: nil)
                self.performSegue(withIdentifier: "getLocker", sender: nil)
            } else {
                if userCanCreateLockers {
                    showAlert()
                } else {
                    if !userCanViewAddresses {
                        let alertController = UIAlertController(title: "No proper right", message: "You don't have right to add lockers. Contact admistrator or scan another locker.", preferredStyle: UIAlertController.Style.alert)
                        let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                        alertController.addAction(okBut)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let alertController = UIAlertController(title: "Temporary locker", message: "You don't have right to add lockers. You can put the parcel into unregistered locker. Do you want to do that?", preferredStyle: UIAlertController.Style.alert)
                        let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                            self.performSegue(withIdentifier: "addVirtualLocker", sender: nil)
                        })
                        let okCancel = UIAlertAction(title: "cancel", style: UIAlertAction.Style.default, handler: nil)
                        alertController.addAction(okBut)
                        alertController.addAction(okCancel)
                        self.present(alertController, animated: true, completion: nil)
                       //
                        //VIEW ADD VIRTUAL LOCKER (choose Adress from list -> type number from locker front door -> type comments)
                    }
                }
            }
        }
        if requestID == CHECK_USERS_REQUEST {
            let userXRights: JSON = getJSON(json: json, desiredKey: KEY_userRights)
            userCanCreateLockers = userHaveRight(rights: userXRights, code: "CREATE_LOCKER")
            userCanViewAddresses = userHaveRight(rights: userXRights, code: "READ_ADDRESS")
            let keys = [KEY_address, KEY_city, KEY_state]
            let val = keys.joined(separator: ".")
            let param = [KEY_qrCode: qrCode!, "expand": val] as NSDictionary
            restRequests.checkForRequest(parameters: param, requestID: LOCKERS_REQUEST)
        }
    }
    
    private func showAlert(){
        let alertController = UIAlertController(title: "Locker not found",
                                                message: "This locker was not found in database. Would you like to add it?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("OK")
            //self.codeWasdetected = false
            self.performSegue(withIdentifier: "addLockerSegue", sender: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
            print("Cancel")
            self.codeWasdetected = false
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            //view.bringSubviewToFront(messageFrame)
            //messageFrame.isHidden = false

            if metadataObj.stringValue != nil && !codeWasdetected {
                codeWasdetected = true
               // msglabel.text = metadataObj.stringValue
               // let generator = UIImpactFeedbackGenerator(style: .heavy)
               // generator.impactOccurred()
                //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                AudioServicesPlayAlertSound(1105) //1352
                qrCode = metadataObj.stringValue
                if let userId: Int = UserDefaults.standard.object(forKey: "userId") as? Int {
                    let param = [KEY_userId: userId] as NSDictionary
                    restRequests.checkForRequest(parameters: param, requestID: CHECK_USERS_REQUEST)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addLockerSegue" {
            let navigationcontroller = segue.destination as? UINavigationController
            let dest = navigationcontroller?.viewControllers.first as! AddLockerViewController
            dest.qrCode = qrCode
        }
        if segue.identifier == "getLocker" {
            let navigationcontroller = segue.destination as? UINavigationController
            let dest = navigationcontroller?.viewControllers.first as! SecurityCodeViewController
            dest.resident = resident
            dest.lockerId = lockerId
            dest.lockerHistory = lockerHistory
           
        }
//        if segue.identifier == "existingLockerToResidentsSegue" {
//            let navigationcontroller = segue.destination as? UINavigationController
//            let dest = navigationcontroller?.viewControllers.first as! AddResidentViewController
//            dest.qrCode = qrCode
//        }
    }
    
}
extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.size.height-100, width: self.view.frame.size.width-10, height: 75))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

