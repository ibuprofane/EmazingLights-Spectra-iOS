//
//  ColorDot.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/16/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import UIKit

class ColorDotView: UIView {

    var color:UIColor = UIColor.orangeColor()
    var baseColor:UIColor = UIColor.orangeColor() //Used to determine name when tint is involed
    var image:UIImage!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        if(image == nil)
        {
            image = self.createDotImage(self.frame)
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0, image.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextDrawImage(context, rect, image.CGImage)
    }
    
    func createDotImage(rect:CGRect)->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        var glowColor = UIColor(white: 1.0, alpha: 1.0)
        if(color == UIColor.blackColor())
        {
            glowColor = color
        }
        let colors = [glowColor.CGColor,
            self.color.CGColor]
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        let locations: [CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorspace,
            colors, locations)
        
        var innerCircleCenter = CGPoint()
        innerCircleCenter.x = self.frame.width * 0.45
        innerCircleCenter.y = self.frame.height * 0.45
        
        var outerCircleCenter = CGPoint()
        outerCircleCenter.x = self.frame.width / 2
        outerCircleCenter.y = self.frame.height / 2
        let startRadius: CGFloat = 0
        let endRadius: CGFloat = self.frame.width / 2
        
        CGContextDrawRadialGradient(context, gradient, innerCircleCenter, startRadius, outerCircleCenter, endRadius, CGGradientDrawingOptions.DrawsBeforeStartLocation)
        
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func getImage() -> UIImage {
        if(image == nil)
        {
            image = self.createDotImage(self.frame)
        }
        return image
    }
    
    func assignColor(color:UIColor, tint:String = "H")
    {
        self.baseColor = color
        
        if(tint == "H")
        {
            self.color = color
        }
        else if(tint == "M")
        {
            self.color = color.darkerColor(0.3)
        }
        else if(tint == "L")
        {
            self.color = color.darkerColor(0.5)
        }
        
        if(self.color.hexString(false) != UIColor.blackColor().hexString(false))
        {
            self.image = self.createDotImage(self.frame)
        }
        else
        {
            self.image = UIImage(named: "BlankDot")
        }
        self.setNeedsDisplay()
    }
    
    func assignAsDisabled()
    {
        self.image = UIImage(named: "DisabledDot")
        self.setNeedsDisplay()
    }
}

class ColorDotImage:UIImage
{
    
}
