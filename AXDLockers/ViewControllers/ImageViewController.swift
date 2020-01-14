//
//  ImageViewController.swift
//  AXDLockers
//
//  Created by Paul Oprea on 22/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage!
    var croppingRect: CGRect!
    var activityIndicator: UIActivityIndicatorView!
    var mainAnnotation: Annotation!
    var cropper: CropperView!

    @IBOutlet weak var detectButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var instructionStackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = setupCloseButton(viewController: self)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchDown)
        setupActivityIndicator()
    
        detectButton.titleLabel?.textAlignment = .center
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let resizedImage = resize(image: image, to: view.frame.size) else {
            fatalError("Error resizing image")
        }
        image = resizedImage
        let imageView = UIImageView(frame: view.frame)
        imageView.image = resizedImage
        imageView.tag = 100
        
        view.addSubview(imageView)
        view.bringSubviewToFront(instructionStackView)
        view.bringSubviewToFront(detectButton)
        cropper = CropperView(
                   frame: CGRect(
                       x: view.bounds.width/4,
                       y: view.bounds.height/2-view.bounds.width/4,
                       width: view.bounds.width/2,
                       height: view.bounds.width/2),
                   into: view!)
    }
    
    private func resize(image: UIImage, to targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height + 1)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    @IBAction func tapDetectText(_ sender: Any) {
        croppingRect = cropper.getCroppingRect()
        let croppedCGImage = image.cgImage?.cropping(to: croppingRect)
        let croppedImage = UIImage(cgImage: croppedCGImage!)
        detectBoundingBoxes(for: croppedImage)
    }
    
    private func detectBoundingBoxes(for image: UIImage) {
        activityIndicator.startAnimating()
        mainAnnotation = nil
        GoogleCloudOCR().detect(from: image) { ocrResult in
            self.activityIndicator.stopAnimating()
            guard let ocrResult = ocrResult else {
                let alertController = UIAlertController(title: "No text", message: "Did not recognize any text in this image.", preferredStyle: UIAlertController.Style.alert)
                let okBut = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                alertController.addAction(okBut)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //print("Found \(ocrResult.annotations.count) bounding box annotations in the image!")
            self.displayBoundingBoxes(for: ocrResult)
        }
    }
    
    private func displayBoundingBoxes(for ocrResult: OCRResult) {
//        let substrings = ocrResult.annotations[0].text.split(separator: "\n")
//        var i = 1
//        for str in substrings{
//            print("line \(i): \(str)")
//            i += 1
//        }
        mainAnnotation = ocrResult.annotations[0]
        for annotation in ocrResult.annotations[1...] {
            //print(annotation.text)
            let path = createBoundingBoxPath(along: annotation.boundingBox.vertices)
            let shape = shapeForBoundingBox(path: path)
            
            view.layer.addSublayer(shape)
        }
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(detectionIsDone), userInfo: nil, repeats: false)
    }
    
    private func createBoundingBoxPath(along vertices: [Vertex]) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: vertices[0].toCGPoint())
        for vertex in vertices[1...] {
            path.addLine(to: vertex.toCGPoint())
        }
        path.close()
        return path
    }
    
    private func shapeForBoundingBox(path: UIBezierPath) -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.lineWidth = 1.5
        shape.strokeColor = UIColor.blue.cgColor
        shape.fillColor = UIColor.blue.withAlphaComponent(0.1).cgColor
        shape.path = path.cgPath
        
        shape.transform = CATransform3DMakeTranslation( croppingRect.minX, croppingRect.minY, 0)
        return shape
    }
   
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = UIColor.darkGray
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    

    @objc private func closeAction() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func detectionIsDone(){
        performSegue(withIdentifier: "backToResult", sender: nil)
    }
  
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destination.
//         Pass the selected object to the new view controller.
        
        if segue.identifier == "backToResult",
            let navVC = segue.destination as? UINavigationController,
            let destination = navVC.viewControllers.first as? OCRResultViewController {
            let substrings = mainAnnotation.text.split(separator: "\n")
            
            if substrings.count > 0 {
                destination.line1 = String(substrings[0])
            }
            if substrings.count > 1 {
                let line2SetMinus = substrings[1].components(separatedBy: "-")
                let line2SetUnit = substrings[1].uppercased().components(separatedBy: "UNIT")
                if line2SetMinus.count > 1 {
                    destination.line2 = String(line2SetMinus[0].trimmingCharacters(in: .whitespaces))
                    if line2SetMinus.count > 2 {
                        destination.line4Street = String(substrings[1].split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)[1].trimmingCharacters(in: .whitespaces))
                    } else {
                        destination.line4Street = String(line2SetMinus[1].trimmingCharacters(in: .whitespaces))
                    }
                }
                if line2SetUnit.count > 1 {
                    destination.line4Street = String(line2SetUnit[0].trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(",".unicodeScalars)))
                    let unit = String(line2SetUnit[1].trimmingCharacters(in: .whitespaces))
                    destination.line2 = String(unit.filter {$0.isNumber})
                }
                
            }
            if substrings.count > 2 {
                destination.line3Address = String(substrings[2])
            }
        }
    }
   

}
