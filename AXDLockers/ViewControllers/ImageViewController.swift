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
    @IBOutlet weak var topLeftCircle: UIView!
    @IBOutlet weak var topLeftDot: UIView!
    @IBOutlet weak var topRightCircle: UIView!
    @IBOutlet weak var topRightDot: UIView!
    @IBOutlet weak var bottomLeftCircle: UIView!
    @IBOutlet weak var bottomLeftDot: UIView!
    @IBOutlet weak var bottomRightCircle: UIView!
    @IBOutlet weak var bottomRightDot: UIView!
    @IBOutlet weak var detectButton: UIButton!
    @IBOutlet weak var instructionsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let resizedImage = resize(image: image, to: view.frame.size) else {
            fatalError("Error resizing image")
        }
        image = resizedImage
        let imageView = UIImageView(frame: view.frame)
        imageView.image = resizedImage
        imageView.tag = 100
        
        view.addSubview(imageView)
        let closeButton = setupCloseButton(viewController: self)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchDown)
        setupActivityIndicator()
        
        view.bringSubviewToFront(instructionsLabel)
        view.bringSubviewToFront(detectButton)
        detectButton.titleLabel?.textAlignment = .center
        
        croppingRect = CGRect(x: view.bounds.width/4, y: view.bounds.height/2-view.bounds.width/4, width: view.bounds.width/2, height: view.bounds.width/2)
        
        let cropPath = CGPath(rect: croppingRect, transform: nil)
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.strokeColor = UIColor.darkGray.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.path = cropPath
        shape.name = "cropPath"
        view.layer.addSublayer(shape)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        topLeftDot.layer.cornerRadius = 5
        topLeftCircle.tag = 51
        topLeftCircle.translatesAutoresizingMaskIntoConstraints = false
        topLeftCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: croppingRect.minX-topLeftCircle.frame.width/2).isActive = true
        topLeftCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: croppingRect.minY-topLeftCircle.frame.height/2).isActive = true
        addPanGesture(view: topLeftCircle)
        view.bringSubviewToFront(topLeftCircle)
        
        
        topRightDot.layer.cornerRadius = 5
        topRightCircle.tag = 52
        topRightCircle.translatesAutoresizingMaskIntoConstraints = false
        topRightCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: croppingRect.maxX-topRightCircle.frame.width/2).isActive = true
        topRightCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: croppingRect.minY-topRightCircle.frame.height/2).isActive = true
        addPanGesture(view: topRightCircle)
        view.bringSubviewToFront(topRightCircle)
        
        bottomLeftDot.layer.cornerRadius = 5
        bottomLeftCircle.tag = 53
        bottomLeftCircle.translatesAutoresizingMaskIntoConstraints = false
        bottomLeftCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: croppingRect.minX-bottomLeftCircle.frame.width/2).isActive = true
        bottomLeftCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: croppingRect.maxY-bottomLeftCircle.frame.height/2).isActive = true
        addPanGesture(view: bottomLeftCircle)
        view.bringSubviewToFront(bottomLeftCircle)
        
        bottomRightDot.layer.cornerRadius = 5
        bottomRightCircle.tag = 54
        bottomRightCircle.translatesAutoresizingMaskIntoConstraints = false
        bottomRightCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: croppingRect.maxX-bottomRightCircle.frame.width/2).isActive = true
        bottomRightCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: croppingRect.maxY-bottomRightCircle.frame.height/2).isActive = true
        addPanGesture(view: bottomRightCircle)
        view.bringSubviewToFront(bottomRightCircle)
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
        activityIndicator.tintColor = UIColor.darkGray
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
    
    func addPanGesture(view: UIView){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        view.addGestureRecognizer(pan)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        let node = sender.view!
        switch sender.state {
        case .began, .changed:
            moveViewWithPan(view: node, sender: sender)
        default:
            break
        }
    }
    
    func moveViewWithPan(view: UIView, sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
        
        
        switch view.tag {
        case 51:
            topRightCircle.center = CGPoint(x: topRightCircle.center.x, y: view.center.y + translation.y)
            bottomLeftCircle.center = CGPoint(x: view.center.x + translation.x, y: bottomLeftCircle.center.y)
        case 52:
            topLeftCircle.center = CGPoint(x: topLeftCircle.center.x, y: view.center.y + translation.y)
            bottomRightCircle.center = CGPoint(x: view.center.x + translation.x, y: bottomRightCircle.center.y)
        case 53:
            bottomRightCircle.center = CGPoint(x: bottomRightCircle.center.x, y: view.center.y + translation.y)
            topLeftCircle.center = CGPoint(x: view.center.x + translation.x, y: topLeftCircle.center.y)
        case 54:
            bottomLeftCircle.center = CGPoint(x: bottomLeftCircle.center.x, y: view.center.y + translation.y)
            topRightCircle.center = CGPoint(x: view.center.x + translation.x, y: topRightCircle.center.y)
        default:
            break
        }
        croppingRect = CGRect(x: topLeftCircle.center.x, y: topLeftCircle.center.y, width: topRightCircle.center.x - bottomLeftCircle.center.x, height: bottomLeftCircle.center.y - topLeftCircle.center.y)
        let cropPath = CGPath(rect: croppingRect, transform: nil)
        if let sublayers = self.view.layer.sublayers {
            for layer in sublayers {
                if layer.name == "cropPath" {
                    let shape = layer as! CAShapeLayer
                    shape.path = cropPath
                }
            }
        }
        
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
            if substrings.count > 2 {
                destination.line1 = String(substrings[0])
                destination.line2 = String(substrings[1])
                destination.line3 = String(substrings[2])
            }
        }
    }
   

}
