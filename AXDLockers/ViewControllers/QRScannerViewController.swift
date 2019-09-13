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
import Alamofire


class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, RestRequestsDelegate {
    
    
    
   @IBOutlet weak var intructionsStackView: UIStackView!
    @IBOutlet weak var labelinfo: UILabel!
    @IBOutlet weak var iconinfo: UIImageView!
    
   
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var codeWasdetected: Bool = false
    
    let restRequests = RestRequests()
    var qrCode: String!
    var resident: BuildingXResident!
    var lockerId: Int!
    var lockerHistory: LockerHistory!
    var userCanCreateLockers: Bool = false
    var userCanViewAddresses: Bool = false
    var userCanCreateParcels: Bool = false
    var addLockerOnly: Bool = false
    var virtualLocker: Bool = false
    @IBOutlet weak var backButtonFromMain: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        restRequests.delegate = self
        navigationController?.isNavigationBarHidden = true
//        navigationController?.navigationBar.backgroundColor = UIColor.clear
//        navigationController?.navigationBar.isTranslucent = false
        var captureDevice: AVCaptureDevice!
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
            captureDevice = device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            captureDevice = device
        } else {
            return
        }

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
       
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
     
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView) //view
            view.bringSubviewToFront(qrCodeFrameView) //view
        }
        view.bringSubviewToFront(backButtonFromMain)
        // Move the message label and icon to the front
        //view.sendSubviewToBack(intructionsStackView)
        view.bringSubviewToFront(intructionsStackView)
//        view.bringSubviewToFront(iconinfo)
//        view.bringSubviewToFront(labelinfo)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = self.view.bounds;
        videoPreviewLayer?.frame = self.view.bounds;
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation;
        switch (orientation) {
        case .portrait:
            videoPreviewLayer?.connection?.videoOrientation = .portrait
        case .landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeLeft
        case .landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = .landscapeRight
        case .portraitUpsideDown:
            videoPreviewLayer?.connection?.videoOrientation = .portraitUpsideDown
        default:
            videoPreviewLayer?.connection?.videoOrientation = .portrait
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //backButtonFromMain.isHidden = !addLockerOnly
        if let code = UserDefaults.standard.object(forKey: "codeWasdetected") as? Bool {
            codeWasdetected = code
            print(codeWasdetected)
        } else {
            codeWasdetected = false
        }
        if codeWasdetected {
            if let decoded  = UserDefaults.standard.data(forKey: "locker") {
                do {
                    let locker = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as? Locker//unarchivedObject(ofClass: Address.self, from: decoded)
                    lockerId = locker?.id
                    lockerHistory = LockerHistory(locker: locker!, resident: resident)
                    
                } catch {
                    print("Address could not be unarchived")
                }
            }
        }
        
        
    }

    
    
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        if let _ = errorCode {
            self.showToast(message: "Error code: \(errorCode!) - \(errorMessage)")
        }
    }
    
    func resultedData(data: Data!, requestID: Int) {
        let json = try? JSON(data: data)
        if requestID == LOCKERS_REQUEST {
            let items: JSON = getJSON(json: json, desiredKey: KEY_items)
            print(items.count)
            if items.count > 0 && codeWasdetected {
                if userCanCreateParcels {
                    let locker = items[0]
                    lockerId = locker[KEY_id].int!
                
                    print("item found - \(lockerId!)")
                    if addLockerOnly {
                        
                        let alertController = UIAlertController(title: "Already exist", message: "This locker was already added in database. Try to add another one.", preferredStyle: UIAlertController.Style.alert)
                        let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {alert -> Void in
                            self.codeWasdetected = false
                        })
                        alertController.addAction(okBut)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        let lockerAddress = Address(street: locker[KEY_address][KEY_streetName].string!, id: locker[KEY_address][KEY_id].int!, cityName: locker[KEY_address][KEY_city][KEY_name].string!, stateName: locker[KEY_address][KEY_city][KEY_state][KEY_name].string!, zipCode: locker[KEY_address][KEY_zipCode].string!)
                        let lockerModel = Locker(id: lockerId, qrCode: qrCode, number: locker[KEY_number].string!, size: locker[KEY_size].string!, address: lockerAddress)
                        if let associatedParcels = getJSON(json: locker, desiredKey: KEY_parcel) {
                            var parcels = [Parcel]()
                            for (_, value) in associatedParcels{
                                let oldResident = BuildingXResident(id: value[KEY_buildingResident][KEY_resident][KEY_id].int!, firstName: value[KEY_buildingResident][KEY_resident][KEY_firstName].string!, lastName: value[KEY_buildingResident][KEY_resident][KEY_lastName].string!, phone: value[KEY_buildingResident][KEY_resident][KEY_phone].string!, email: value[KEY_buildingResident][KEY_resident][KEY_email].string!, suiteNumber: value[KEY_buildingResident][KEY_suiteNumber].string!, buildingResidentId: value[KEY_buildingResident][KEY_id].int!)
                                
                                let oldBuildingAddressKeys = [value[KEY_buildingResident][KEY_building][KEY_address][KEY_zipCode].string!, value[KEY_buildingResident][KEY_building][KEY_address][KEY_streetName].string!, value[KEY_buildingResident][KEY_building][KEY_address][KEY_city][KEY_name].string!, value[KEY_buildingResident][KEY_building][KEY_address][KEY_city][KEY_state][KEY_name].string!]
                                let oldBuildingAddress = oldBuildingAddressKeys.joined(separator: ", ")
                                let oldBuilding = Building(id: value[KEY_buildingResident][KEY_building][KEY_id].int!, name: value[KEY_buildingResident][KEY_building][KEY_name].string!, address: oldBuildingAddress, buidingUniqueNumber: value[KEY_buildingResident][KEY_building][KEY_buildingUniqueNumber].string!)
                                
                                let parcel = Parcel(id: value[KEY_id].int!, lockerId: value[KEY_lockerId].int!, buildingResidentId: value[KEY_buildingResidentId].int!, securityCode: value[KEY_securityCode].string!, status: value[KEY_status].int!, buildingResident: oldResident, building: oldBuilding)
                                parcels.append(parcel)
                            }
                            lockerModel.parcels = parcels
                        }
                        lockerHistory = LockerHistory(locker: lockerModel, resident: resident)
                        if lockerModel.isLockerFree() {
                            self.performSegue(withIdentifier: "getLocker", sender: nil)
                        } else {
                            let alertController = UIAlertController(title: "Locker occupied",
                                                                    message: "This locker appear in system as not being free. Are you sure you want to use it? (This action will force release the locker in the system)",
                                                                    preferredStyle: UIAlertController.Style.alert)
                            
                            let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                                
                                let parameter:Parameters = [KEY_id: lockerModel.parcels[0].id] as Parameters
                                self.restRequests.checkForRequest(parameters: parameter, requestID: DELETE_LOCKER_BUILDING_RESIDENT_REQUEST)
                            })
                            let okCancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {alert -> Void in
                                self.codeWasdetected = false
                            })
                            alertController.addAction(okBut)
                            alertController.addAction(okCancel)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
                } else {
                    let alertController = UIAlertController(title: "No proper rights", message: "You don't have right to add parcels into lockers. Contact administrator.", preferredStyle: UIAlertController.Style.alert)
                    let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { alert -> Void in
                        self.codeWasdetected = false
                    })
                    alertController.addAction(okBut)
                    self.present(alertController, animated: true, completion: nil)
                }
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
                            self.virtualLocker = true
                            self.performSegue(withIdentifier: "addLockerSegue", sender: nil)
                        })
                        let okCancel = UIAlertAction(title: "cancel", style: UIAlertAction.Style.default, handler: {alert -> Void in
                            self.codeWasdetected = false
                        })
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
            userCanCreateParcels = userHaveRight(rights: userXRights, code: "CREATE_PACKAGES")
            let keys0 = [KEY_address, KEY_city, KEY_state]
            let keys1 = [KEY_parcel, KEY_buildingResident, KEY_resident]
            let keys2 = [KEY_parcel, KEY_buildingResident, KEY_building, KEY_address, KEY_city, KEY_state]
            let val0 = keys0.joined(separator: ".")
            let val1 = keys1.joined(separator: ".")
            let val2 = keys2.joined(separator: ".")
            let keys = [val0, val1, val2]
            let param = [
                addREST_Filter(parameters: [KEY_qrCode])  : qrCode!,
                "expand": keys.joined(separator: ",")
                ] as Parameters
            restRequests.checkForRequest(parameters: param, requestID: LOCKERS_REQUEST)
        }
        
        if requestID == DELETE_LOCKER_BUILDING_RESIDENT_REQUEST {
            let lockerAddressArray = [lockerHistory.locker.address.zipCode, lockerHistory.locker.address.street, lockerHistory.locker.address.cityName, lockerHistory.locker.address.stateName]
            let oldResident = lockerHistory.locker.parcels[0].buildingResident
            let oldBuilding = lockerHistory.locker.parcels[0].building
            let body = [
                KEY_qrCode: lockerHistory.locker.qrCode,
                KEY_number: lockerHistory.locker.number,
                KEY_size: lockerHistory.locker.size,
                KEY_phone: oldResident.phone,
                KEY_lockerAddress: lockerAddressArray.joined(separator: ", "),
                KEY_firstName: oldResident.firstName,
                KEY_lastName: oldResident.lastName,
                KEY_email: oldResident.email,
                KEY_securityCode: lockerHistory.locker.parcels[0].securityCode,
                KEY_suiteNumber: oldResident.suiteNumber,
                KEY_buildingUniqueNumber: oldBuilding.buidingUniqueNumber,
                KEY_name: oldBuilding.name,
                KEY_buildingAddress: oldBuilding.address,
                "residentAddress": oldBuilding.address,
                "createdByEmail": UserDefaults.standard.object(forKey: "userEmail") as! String,
                "packageStatus": "FORCED FREE",
                "createdByFirstName": UserDefaults.standard.object(forKey: "userFirstName") as! String,
                "createdByLastName": UserDefaults.standard.object(forKey: "userLastName") as! String
            ] as [String : Any]
            
            restRequests.checkForRequest(parameters: nil, requestID: INSERT_LOCKER_HISTORIES_REQUEST, body: body as NSDictionary)
        }
        
        if requestID == INSERT_LOCKER_HISTORIES_REQUEST {
            let alertController = UIAlertController(title: "LOCKER FREE", message: "The locker was set to FREE. Scan the QRCode again to use it.", preferredStyle: UIAlertController.Style.alert)
            let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{ action in
                self.codeWasdetected = false
            })
            alertController.addAction(okBut)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showAlert(){
        let alertController = UIAlertController(title: "Locker not found",
                                                message: "This locker was not found in database. Would you like to add it?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//            print("OK")
            //self.codeWasdetected = false
            self.virtualLocker = false
            self.performSegue(withIdentifier: "addLockerSegue", sender: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{ action in
//            print("Cancel")
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
                if let _ = UserDefaults.standard.object(forKey: "userId") as? Int {
                    //let param = [KEY_userId: userId] as NSDictionary
                    restRequests.checkForRequest(parameters: nil, requestID: CHECK_USERS_REQUEST)
                }
            }
        }
    }
    @IBAction func onBack(_ sender: Any) {
        
        if addLockerOnly {
            dismiss(animated: true, completion:nil)
        } else {
            navigationController?.isNavigationBarHidden = false
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "addLockerSegue" {
            let navigationcontroller = segue.destination as? UINavigationController
            let dest = navigationcontroller?.viewControllers.first as! AddLockerViewController
            dest.qrCode = qrCode
            dest.addLockerOnly = addLockerOnly
            dest.virtualLocker = virtualLocker
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
        
        let toastLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.size.height-100, width: self.view.frame.size.width-20, height: 75))
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
        UIView.animate(withDuration: 4.0, delay: 1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

