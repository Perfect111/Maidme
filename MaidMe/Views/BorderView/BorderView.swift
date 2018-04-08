//
//  BorderView.swift
//  MaidMe
//
//  Created by Viktor on 3/2/16.
//  Copyright © 2016 Mac. All rights reserved.
//

import UIKit

@IBDesignable class BorderView: UIView {

    var shapeLayer: CAShapeLayer!
    
    @IBInspectable var borderRadius: Float {
        get {
            return Float(layer.cornerRadius)
        }
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return CGFloat(layer.borderWidth)
        }
        set {
            layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.lightGray {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return CGFloat(layer.cornerRadius)
        }
        set {
            layer.masksToBounds = newValue > 0
            layer.cornerRadius = CGFloat(newValue)
        }
    }
    
    @IBInspectable var dashPattern: Int = 0
    @IBInspectable var spacePattern: Int = 0
    
    @IBInspectable var borderType: BorderType = .solid {
        didSet {
            drawDashedBorder()
        }
    }
    
    func drawDashedBorder() {
        if (shapeLayer != nil) {
            shapeLayer.removeFromSuperlayer()
        }
   
        let lineColor = borderColor
        let frame = self.bounds
    
        shapeLayer = CAShapeLayer()
    
        //creating a path
        let path = CGMutablePath()
    
        //drawing a border around a view
path.move(to: CGPoint(x: 0, y: frame.size.height - cornerRadius))
       
        path.move(to: CGPoint(x: 0, y: cornerRadius))
       
        path.addArc(center: CGPoint(x:cornerRadius,y:cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi/2, clockwise: false)
       
        path.addLine(to: CGPoint(x: frame.size.width - cornerRadius, y: 0))
       
        path.addArc(center: CGPoint(x:frame.size.width - cornerRadius,y:cornerRadius), radius: cornerRadius, startAngle: -CGFloat.pi/2, endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height - cornerRadius))
       
        path.addArc(center: CGPoint(x:frame.size.width - cornerRadius,y:frame.size.height - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat.pi/2, clockwise: false)
     
        path.addLine(to: CGPoint(x: cornerRadius, y: frame.size.height))
        
        path.addArc(center: CGPoint(x:cornerRadius, y:frame.size.height - cornerRadius), radius: cornerRadius, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi, clockwise: false)
       
        //path is set as the _shapeLayer object's path
        shapeLayer.path = path
    
        shapeLayer.backgroundColor = UIColor.clear.cgColor// [[UIColor clearColor] CGColor];
        shapeLayer.frame = frame
        shapeLayer.masksToBounds = false
        shapeLayer.setValue(NSNumber(value: false as Bool), forKey: "isCircle")
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = borderWidth
        if borderType == .dashed{
            shapeLayer.lineDashPattern = [NSNumber(integerLiteral:dashPattern),NSNumber(integerLiteral:spacePattern)]
        }else{
            shapeLayer.lineDashPattern = nil
        }
       
        shapeLayer.lineCap = kCALineCapRound
    
        //_shapeLayer is added as a sublayer of the view
        self.layer.addSublayer(shapeLayer)
        self.layer.cornerRadius = cornerRadius
    }

}

@objc enum BorderType: Int {
    case dashed = 0
    case solid = 1
}
