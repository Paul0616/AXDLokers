//
//  ViewController.swift
//  AXDLokers
//
//  Created by Paul Oprea on 18/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import AVFoundation


class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, RestRequestsDelegate {
    
    
    
    @IBOutlet weak var messageLabel: UILabel!
   // @IBOutlet weak var messageFrame: UIView!
   // @IBOutlet weak var msglabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
  //  @IBOutlet weak var closePopup: UIButton!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var codeWasdetected: Bool = false
    
    let restRequests = RestRequests()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        restRequests.delegate = self
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
       
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
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
        view.bringSubviewToFront(logOutButton)
        // Move the message label and top bar to the front
        view.bringSubviewToFront(messageLabel)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        //messageFrameView = UIView()
       // msgLabel = UILabel()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView) //view
            view.bringSubviewToFront(qrCodeFrameView) //view
        }

    }
//    @IBAction func closePopupAction(_ sender: UIButton) {
//        codeWasdetected = false
//        //messageFrame.isHidden = true
//    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "isSuperAdmin")
        UserDefaults.standard.removeObject(forKey: "tokenExpiresAt")
        UserDefaults.standard.removeObject(forKey: "encryptedPassword")
        Switcher.updateRootVC(isLogged: false)
    }
    
    func treatErrors(_ errorCode: Int!, errorMessage: String) {
        print(errorMessage)
        self.showToast(message: "Error code: \(errorCode!)")
    }
    
    func resultedData(data: Data!, requestID: Int) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
            
            let items = json["items"] as! NSArray
            print(items.count)
            if items.count > 0 {
                print("item found")
            } else {
               showAlert()
            }
        } catch let error as NSError
        {
            print(error)
        }
    }
    
    private func showAlert(){
        let alertController = UIAlertController(title: "Locker not found",
                                                message: "This QRCode was not found in database. Would you like to add it and associate it with new locker?",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            print("OK")
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
                
                let param = [qrCodeREST_Key: metadataObj.stringValue!] as NSDictionary
                restRequests.checkForRequest(parameters: param, requestID: LOCKERS_REQUEST)
            }
        }
    }
}
extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 75))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

