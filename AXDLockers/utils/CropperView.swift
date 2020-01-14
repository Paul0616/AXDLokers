//
//  MyView.swift
//  drag
//
//  Created by Paul Oprea on 14/01/2020.
//  Copyright © 2020 Paul Oprea. All rights reserved.
//

import UIKit

class CropperView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var lastLocation = CGPoint(x: 0, y: 0)
    var container: UIView = UIView()
    let topLeftDot = UIView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 10.0))
    let topRightDot = UIView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 10.0))
    let bottomLeftDot = UIView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 10.0))
    let bottomRightDot = UIView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 10.0))
    let topLeftHandler = UIView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
    let topRightHandler = UIView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
    let bottomLeftHandler = UIView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
    let bottomRightHandler = UIView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
    
    required init(frame: CGRect, into: UIView) {
        super.init(frame: frame)
        self.container = into
        // Initialization code
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(CropperView.detectPan(_:)))
        self.gestureRecognizers = [panRecognizer]
        
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 1.0
        //self.backgroundColor = UIColor(red:redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        into.addSubview(self)
    
        topLeftDot.layer.cornerRadius = 5.0
        topLeftDot.backgroundColor = UIColor(red: 248/255, green: 107/255, blue: 45/255, alpha: 1.0)
        topLeftHandler.tag = 10
        topLeftHandler.layer.cornerRadius = 20.0
        
        topRightDot.layer.cornerRadius = 5.0
        topRightDot.backgroundColor = UIColor(red: 248/255, green: 107/255, blue: 45/255, alpha: 1.0)
        topRightHandler.tag = 11
        topRightHandler.layer.cornerRadius = 20.0
        
        bottomLeftDot.layer.cornerRadius = 5.0
        bottomLeftDot.backgroundColor = UIColor(red: 248/255, green: 107/255, blue: 45/255, alpha: 1.0)
        bottomLeftHandler.tag = 12
        bottomLeftHandler.layer.cornerRadius = 20.0
        
        bottomRightDot.layer.cornerRadius = 5.0
        bottomRightDot.backgroundColor = UIColor(red: 248/255, green: 107/255, blue: 45/255, alpha: 1.0)
        bottomRightHandler.tag = 13
        bottomRightHandler.layer.cornerRadius = 20.0
        
        setTopLeft()
        setTopRight()
        setBottomLeft()
        setBottomRight()
        into.addSubview(topLeftDot)
        container.bringSubviewToFront(topLeftDot)
        into.addSubview(topRightDot)
        into.addSubview(bottomLeftDot)
        into.addSubview(bottomRightDot)
        into.addSubview(topLeftHandler)
        into.addSubview(topRightHandler)
        into.addSubview(bottomLeftHandler)
        into.addSubview(bottomRightHandler)
        addPanGesture(view: topLeftHandler)
        addPanGesture(view: topRightHandler)
        addPanGesture(view: bottomLeftHandler)
        addPanGesture(view: bottomRightHandler)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setTopLeft() {
        let halfWidth = self.frame.size.width / 2
        let halfHeight = self.frame.size.height / 2
        topLeftDot.center = CGPoint(x: self.center.x - halfWidth, y: self.center.y - halfHeight)
        topLeftHandler.center = topLeftDot.center
    }
    fileprivate func setTopRight() {
        let halfWidth = self.frame.size.width / 2
        let halfHeight = self.frame.size.height / 2
        topRightDot.center = CGPoint(x: self.center.x + halfWidth, y: self.center.y - halfHeight)
        topRightHandler.center = topRightDot.center
    }
    fileprivate func setBottomLeft() {
        let halfWidth = self.frame.size.width / 2
        let halfHeight = self.frame.size.height / 2
        bottomLeftDot.center = CGPoint(x: self.center.x - halfWidth, y: self.center.y + halfHeight)
        bottomLeftHandler.center = bottomLeftDot.center
    }
    fileprivate func setBottomRight() {
        let halfWidth = self.frame.size.width / 2
        let halfHeight = self.frame.size.height / 2
        bottomRightDot.center = CGPoint(x: self.center.x + halfWidth, y: self.center.y + halfHeight)
        bottomRightHandler.center = bottomRightDot.center
    }
    
    @objc private func detectPan(_ recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview)
        var newX = center.x + translation.x
        var newY = center.y + translation.y
        
        if newX <= container.frame.minX + frame.size.width / 2 {
            newX = container.frame.minX + frame.size.width / 2
            print("minX limit - trans \(translation.x)")
        }
        if newX >= container.frame.maxX - frame.size.width / 2 {
            newX = container.frame.maxX - frame.size.width / 2
            print("frame maxX \(frame.maxX)")
            print("maxX limit - trans \(translation.x)")
        }
        
        if newY <= container.frame.minY + frame.size.height / 2 {
            newY = container.frame.minY + frame.size.height / 2
        }
        
        if newY >= container.frame.maxY - frame.size.height / 2 {
            newY = container.frame.maxY - frame.size.height / 2
        }
        
        self.center = CGPoint(x: newX, y: newY)
        
        setTopLeft()
        setTopRight()
        setBottomLeft()
        setBottomRight()
        recognizer.setTranslation(CGPoint.zero, in: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Promote the touched view
        self.superview?.bringSubviewToFront(self)
        
        // Remember original location
        lastLocation = self.center
    }
    
    
    private func addPanGesture(view: UIView){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleDotPan(sender:)))
        view.addGestureRecognizer(pan)
    }

    @objc private func handleDotPan(sender: UIPanGestureRecognizer){
           let node = sender.view!
           switch sender.state {
           case .changed:
               resizeObject(view: node, sender: sender)
           default:
               break
           }
       }
    
    private func resizeObject(view: UIView, sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        if translation == CGPoint(x: 0.0, y: 0.0) {
            return
        }
        view.center.x += translation.x
        view.center.y += translation.y
    
        
        switch view.tag {
        case 10:
            topRightDot.center.y += translation.y
            bottomLeftDot.center.x += translation.x
            topRightHandler.center = topRightDot.center
            bottomLeftHandler.center = bottomLeftDot.center
            topLeftDot.center = view.center
        case 11:
            topLeftDot.center.y += translation.y
            bottomRightDot.center.x += translation.x
            topLeftHandler.center = topLeftDot.center
            bottomRightHandler.center = bottomRightDot.center
            topRightDot.center = view.center
        case 12:
            bottomRightDot.center.y += translation.y
            topLeftDot.center.x += translation.x
            bottomRightHandler.center = bottomRightDot.center
            topLeftHandler.center = topLeftDot.center
            bottomLeftDot.center = view.center
        case 13:
            bottomLeftDot.center.y += translation.y
            topRightDot.center.x += translation.x
            bottomLeftHandler.center = bottomLeftDot.center
            topRightHandler.center = topRightDot.center
            bottomRightDot.center = view.center
        default:
            break
        }
        frame = CGRect(
            x: topLeftDot.center.x,
            y: topLeftDot.center.y,
            width: topRightDot.center.x - bottomLeftDot.center.x,
            height: bottomLeftDot.center.y - topLeftDot.center.y
        )
        
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    func getCroppingRect() -> CGRect{
        return self.frame
    }
}
