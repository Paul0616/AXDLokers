//
//  ViewController.swift
//  AXDLokers
//
//  Created by Paul Oprea on 18/03/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import AVFoundation


class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageFrame: UIView!
    @IBOutlet weak var msglabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
//    var messageFrameView: UIView?
//    var msgLabel: UILabel!
    var codeWasdetected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
       
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        messageFrame.layer.cornerRadius = 6

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
        //messageFrameView = UIView()
       // msgLabel = UILabel()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView) //view
            view.bringSubviewToFront(qrCodeFrameView) //view
        }
//        if let messageFrameView = messageFrameView {
//            messageFrameView.backgroundColor = UIColor(red:0.43, green:0.61, blue:0.59, alpha:1.0)//UIColor.r.cgColor
//            messageFrameView.layer.cornerRadius = 6
//            messageFrameView.translatesAutoresizingMaskIntoConstraints = false
//
//            view.addSubview(messageFrameView) //view
//            view.bringSubviewToFront(messageFrameView)
//            messageFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//            messageFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//            if let msgLabel = msgLabel {
//                msgLabel.text = ""
//                msgLabel.backgroundColor = UIColor(red:0.27, green:0.37, blue:0.36, alpha:1.0)
//                msgLabel.textColor = UIColor.white
//                messageFrameView.addSubview(msgLabel)
//                msgLabel.translatesAutoresizingMaskIntoConstraints = false
//                msgLabel.bottomAnchor.constraint(equalTo: messageFrameView.bottomAnchor).isActive = true
//                msgLabel.widthAnchor.constraint(equalTo: messageFrameView.widthAnchor, multiplier: 1).isActive = true
//                msgLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
//            }
//        }
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "isSuperAdmin")
        UserDefaults.standard.removeObject(forKey: "tokenExpiresAt")
        UserDefaults.standard.removeObject(forKey: "encryptedPassword")
        Switcher.updateRootVC(isLogged: false)
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
            view.bringSubviewToFront(messageFrame)
            messageFrame.isHidden = false

            if metadataObj.stringValue != nil && !codeWasdetected {
                codeWasdetected = true
                msglabel.text = metadataObj.stringValue
//                let generator = UIImpactFeedbackGenerator(style: .heavy)
//                generator.impactOccurred()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
}

