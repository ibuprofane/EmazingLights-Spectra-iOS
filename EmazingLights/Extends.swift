//
//  Created by DaRk-_-D0G on 13/04/2015.
//  Copyright (c) 2015 DaRk-_-D0G. All rights reserved.
//  Yannickstephan.com
//  redwolfstudio.fr

import Foundation
import CoreGraphics

public extension Int {
    /**
     Returns a random integer between 0 and n-1.
     */
    public static func random(n: Int) -> Int {
        return Int(arc4random_uniform(UInt32(n)))
    }
    /**
     Create a random num Int
     - parameter lower: number Int
     - parameter upper: number Int
     :return: random number Int
     By DaRkDOG
     */
    public static func random(min min: Int, max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max - min + 1))) + min
    }
}
public extension Double {
    /**
     Returns a random floating point number between 0.0 and 1.0, inclusive.
     By DaRkDOG
     */
    public static func random() -> Double {
        return Double(arc4random()) / 0xFFFFFFFF
    }
    
    /**
     Create a random num Double
     - parameter lower: number Double
     - parameter upper: number Double
     :return: random number Double
     By DaRkDOG
     */
    public static func random(min min: Double, max: Double) -> Double {
        return Double.random() * (max - min) + min
    }
}
public extension Float {
    /**
     Returns a random floating point number between 0.0 and 1.0, inclusive.
     By DaRkDOG
     */
    public static func random() -> Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }
    /**
     Create a random num Float
     - parameter lower: number Float
     - parameter upper: number Float
     :return: random number Float
     By DaRkDOG
     */
    public static func random(min min: Float, max: Float) -> Float {
        return Float.random() * (max - min) + min
    }
}
public extension CGFloat {
    /**
     Returns a random floating point number between 0.0 and 1.0, inclusive.
     By DaRkDOG
     */
    public static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    /**
     Create a random num CGFloat
     - parameter lower: number CGFloat
     - parameter upper: number CGFloat
     :return: random number CGFloat
     By DaRkDOG
     */
    public static func random(min min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random() * (max - min) + min
    }
}