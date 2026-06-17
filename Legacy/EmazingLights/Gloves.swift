//
//  Gloves.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/23/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation
import UIKit

class Chip:NSObject
{
    var name:String = ""
    var image:UIImage!
    var imageName:String = ""
    var userDescription:String = ""
    var finger:Finger! // Only one per chip
    var fingerDataForRestore:Finger!
    var tags:Set<String> = Set<String>()
    
    init(name:String, imageName:String, finger:Finger, tags:Set<String>?, description:String = "")
    {
        self.name = name
        self.imageName = imageName
        self.image = UIImage(named: imageName)
        self.finger = finger
        self.fingerDataForRestore = finger.copyObject()
        
        if(tags != nil)
        {
            self.tags = tags!
        }
        if(description != "")
        {
            self.userDescription = description
        }
    }
    
    init(name:String, image:UIImage, finger:Finger, tags:Set<String>?, description:String = "")
    {
        self.name = name
        self.image = image
        self.finger = finger
        self.fingerDataForRestore = finger.copyObject()
        
        if(tags != nil)
        {
            self.tags = tags!
        }
        if(description != "")
        {
            self.userDescription = description
        }
    }
    
    func copyObject()->Chip
    {
        var newTagsSet = Set<String>()
        for tag in tags{
            newTagsSet.insert(tag)
        }
        
        return Chip(name: name, image: image, finger: finger.copyObject(), tags: newTagsSet, description: userDescription)
    }
    
    func setChipImageByName(named: String)
    {
        self.image = UIImage(named: named)
    }
    
    func setChipImage(image:UIImage)
    {
        self.image = image
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        
        if(self.imageName == "")
        {
            aCoder.encodeObject(self.image, forKey: "image")
        }
        else
        {
            aCoder.encodeObject(self.imageName, forKey: "imageName")
        }
        
        aCoder.encodeObject(self.finger, forKey: "finger")
        aCoder.encodeObject(self.fingerDataForRestore, forKey: "fingerDataForRestore")
        aCoder.encodeObject(self.tags, forKey: "tags")
        aCoder.encodeObject(self.userDescription, forKey: "userDescription")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("name"))
        {
            self.name = aDecoder.decodeObjectForKey("name") as! String
        }
        if(aDecoder.containsValueForKey("imageName"))
        {
            self.imageName = aDecoder.decodeObjectForKey("imageName") as! String
            self.image = UIImage(named: self.imageName)
        }
        else
        {
            if(aDecoder.containsValueForKey("image"))
            {
                self.image = aDecoder.decodeObjectForKey("image") as! UIImage
            }
        }
        if(aDecoder.containsValueForKey("finger"))
        {
            self.finger = aDecoder.decodeObjectForKey("finger") as! Finger
        }
        if(aDecoder.containsValueForKey("fingerDataForRestore"))
        {
            self.fingerDataForRestore = aDecoder.decodeObjectForKey("fingerDataForRestore") as! Finger
        }
        if(aDecoder.containsValueForKey("tags"))
        {
            self.tags = aDecoder.decodeObjectForKey("tags") as! Set<String>
        }
        if(aDecoder.containsValueForKey("userDescription"))
        {
            self.userDescription = aDecoder.decodeObjectForKey("userDescription") as! String
        }
    }
}

class GloveSet:NSObject
{
    var name:String = ""
    var imageName:String = ""
    var userDescription:String = ""
    var glovePair:[Hand] = [] // 2 gloves per GloveSet expected
    var tags:Set<String> = Set<String>()
    
    init(name:String, imageName:String, glovePair:[Hand], tags:Set<String>?, description:String = "")
    {
        self.name = name
        self.imageName = imageName
        self.glovePair = glovePair
        
        if(tags != nil)
        {
            self.tags = tags!
        }
        if(description != "")
        {
            self.userDescription = description
        }
    }
    
    func copyObject()->GloveSet
    {
        var newHandArray = [Hand]()
        for i in 0 ..< glovePair.count
        {
            newHandArray.append(glovePair[i].copyObject())
        }
        
        var newTagsSet = Set<String>()
        for tag in tags{
            newTagsSet.insert(tag)
        }
        
        return GloveSet(name: name, imageName: imageName, glovePair: newHandArray, tags: newTagsSet, description: userDescription)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.imageName, forKey: "imageName")
        aCoder.encodeObject(self.glovePair, forKey: "glovePair")
        aCoder.encodeObject(self.tags, forKey: "tags")
        aCoder.encodeObject(self.userDescription, forKey: "userDescription")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("name"))
        {
            self.name = aDecoder.decodeObjectForKey("name") as! String
        }
        if(aDecoder.containsValueForKey("imageName"))
        {
            self.imageName = aDecoder.decodeObjectForKey("imageName") as! String
        }
        if(aDecoder.containsValueForKey("glovePair"))
        {
            self.glovePair = aDecoder.decodeObjectForKey("glovePair") as! [Hand]
        }
        if(aDecoder.containsValueForKey("tags"))
        {
            self.tags = aDecoder.decodeObjectForKey("tags") as! Set<String>
        }
        if(aDecoder.containsValueForKey("userDescription"))
        {
            self.userDescription = aDecoder.decodeObjectForKey("userDescription") as! String
        }
    }
}

class Hand:NSObject
{
    var fingers:[Finger] = [] // 5 Fingers
    var handID:Int = 0 // 0=Left, 1=Right
    var emotion:Int = 0
    
    init(handID:Int, emotion:Int, fingers:[Finger])
    {
        self.handID = handID
        self.emotion = emotion
        self.fingers = fingers
    }
    
    func copyObject()->Hand
    {
        var newArray = [Finger]()
        for i in 0 ..< fingers.count
        {
            newArray.append(fingers[i].copyObject())
        }
        
        return Hand(handID: handID, emotion: emotion, fingers: newArray)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.fingers, forKey: "fingers")
        aCoder.encodeObject(self.handID, forKey: "handID")
        aCoder.encodeObject(self.emotion, forKey: "emotion")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("fingers"))
        {
            self.fingers = aDecoder.decodeObjectForKey("fingers") as! [Finger]
        }
        if(aDecoder.containsValueForKey("handID"))
        {
            self.handID = aDecoder.decodeObjectForKey("handID") as! Int
        }
        if(aDecoder.containsValueForKey("emotion"))
        {
            self.emotion = aDecoder.decodeObjectForKey("emotion") as! Int
        }
    }
}

class Finger:NSObject
{
    //NOTE: Disabled Modes is a member of the finger class because a mode might be disabled in one glove set, but enabled in a different glove set.
    var disabledModes:[Bool] = []
    var modes:[Mode] = []
    var otfModes:[Int:Mode] = [:]
    var defaultPalette:Palette!
    
    init(modes:[Mode], defaultPalette:Palette, otfModes:[Int:Mode] = [:])
    {
        self.modes = modes
        for _ in 0..<modes.count
        {
            disabledModes.append(false)
        }
        self.defaultPalette = defaultPalette
        self.otfModes = otfModes
    }
    
    func copyObject()->Finger
    {
        var newArray = [Mode]()
        for i in 0 ..< modes.count
        {
            newArray.append(modes[i].copyObject())
        }
        
        return Finger(modes: newArray, defaultPalette: defaultPalette)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.modes, forKey: "modes")
        aCoder.encodeObject(self.disabledModes, forKey: "disabledModes")
        aCoder.encodeObject(self.defaultPalette, forKey: "defaultPalette")
        aCoder.encodeObject(self.otfModes, forKey: "otfModes")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("modes"))
        {
            self.modes = aDecoder.decodeObjectForKey("modes") as! [Mode]
        }
        if(aDecoder.containsValueForKey("disabledModes"))
        {
            self.disabledModes = aDecoder.decodeObjectForKey("disabledModes") as! [Bool]
        }
        if(aDecoder.containsValueForKey("defaultPalette"))
        {
            self.defaultPalette = aDecoder.decodeObjectForKey("defaultPalette") as! Palette
        }
        if(aDecoder.containsValueForKey("otfModes"))
        {
            self.otfModes = aDecoder.decodeObjectForKey("otfModes") as! [Int:Mode]
        }
    }
}

class Mode:NSObject
{
    var name:String = ""
    var sequences:[Sequence] = [] // 1 or 2 sequences per Mode expected
    var emotionEffect:Int = 0
    var emotionSpeedOption:Int = 0
    var emotionParam1:Int = 0
    var emotionParam2:Int = 0
    var emotionParam3:Int = 0
    
    init(name:String, sequences:[Sequence], emotionEffect:Int = 0, emotionSpeedOption:Int = 0, emotionParam1:Int = 0, emotionParam2:Int = 0, emotionParam3:Int = 0)
    {
        self.name = name
        self.sequences = sequences
        self.emotionEffect = emotionEffect
        self.emotionSpeedOption = emotionSpeedOption
        self.emotionParam1 = emotionParam1
        self.emotionParam2 = emotionParam2
        self.emotionParam3 = emotionParam3
    }
    
    func copyObject()->Mode
    {
        var newArray = [Sequence]()
        for i in 0 ..< sequences.count
        {
            newArray.append(sequences[i].copyObject())
        }
        
        return Mode(name: name, sequences: newArray, emotionEffect: emotionEffect, emotionSpeedOption: emotionSpeedOption,emotionParam1: emotionParam1, emotionParam2:emotionParam2, emotionParam3: emotionParam3)
    }
    
    func updateName()
    {
        //self.name = "\(self.sequences[0].flashingPattern.name.uppercaseString) / \(self.sequences[1].flashingPattern.name.uppercaseString)"
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.sequences, forKey: "sequences")
        aCoder.encodeObject(self.emotionEffect, forKey: "emotionEffect")
        aCoder.encodeObject(self.emotionSpeedOption, forKey: "emotionSpeedOption")
        aCoder.encodeObject(self.emotionParam1, forKey: "emotionParam1")
        aCoder.encodeObject(self.emotionParam2, forKey: "emotionParam2")
        aCoder.encodeObject(self.emotionParam3, forKey: "emotionParam3")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("name"))
        {
            self.name = aDecoder.decodeObjectForKey("name") as! String
        }
        if(aDecoder.containsValueForKey("sequences"))
        {
            self.sequences = aDecoder.decodeObjectForKey("sequences") as! [Sequence]
        }
        if(aDecoder.containsValueForKey("emotionEffect"))
        {
            let emotionEffect = aDecoder.decodeObjectForKey("emotionEffect") as! Int
            if(emotionEffect == -1)
            {
                self.emotionEffect = 0
            }
            else
            {
                self.emotionEffect = emotionEffect
            }
        }
        
        if(aDecoder.containsValueForKey("emotionSpeedOption"))
        {
            self.emotionSpeedOption = aDecoder.decodeObjectForKey("emotionSpeedOption") as! Int
        }
        if(aDecoder.containsValueForKey("emotionParam1"))
        {
            self.emotionParam1 = aDecoder.decodeObjectForKey("emotionParam1") as! Int
        }
        if(aDecoder.containsValueForKey("emotionParam2"))
        {
            self.emotionParam2 = aDecoder.decodeObjectForKey("emotionParam2") as! Int
        }
        if(aDecoder.containsValueForKey("emotionParam3"))
        {
            self.emotionParam3 = aDecoder.decodeObjectForKey("emotionParam3") as! Int
        }
    }
}

class Sequence:NSObject
{
    var flashingPattern:FlashingPattern!
    var colorSet:[Color] = [] // 7 colors per Sequence maximum
    var colorTints:[String] = ["H","H","H","H","H","H","H"] // 7 colors per Sequence maximum
    var maxColors:Int = 7
    var threshold:Int = 0
    var customFP:Bool = false
    
    init(flashingPattern:FlashingPattern, colorSet:[Color], colorTints:[String]? = nil, maxColors:Int = 7, threshold:Int = 0, customFP:Bool = false)
    {
        self.flashingPattern = flashingPattern
        self.colorSet = colorSet
        if(colorTints != nil)
        {
            self.colorTints = colorTints!
        }
        else
        {
            self.colorTints.removeAll()
            for _ in 0..<maxColors
            {
                self.colorTints.append("H")
            }
        }
        
        self.maxColors = maxColors
        self.customFP = customFP
    }
    
    func copyObject()->Sequence
    {
        var newColorArray = [Color]()
        var newTintArray = [String]()
        for i in 0 ..< colorSet.count
        {
            newColorArray.append(colorSet[i])
            newTintArray.append(colorTints[i])
        }
        
        return Sequence(flashingPattern: flashingPattern, colorSet: newColorArray, colorTints: newTintArray, threshold: threshold, customFP: customFP)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.flashingPattern, forKey: "flashingPattern")
        aCoder.encodeObject(self.colorSet, forKey: "colorSet")
        aCoder.encodeObject(self.maxColors, forKey: "maxColors")
        aCoder.encodeObject(self.threshold, forKey: "threshold")
        aCoder.encodeObject(self.colorTints, forKey: "colorTints")
        aCoder.encodeObject(self.customFP, forKey: "customFP")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("flashingPattern"))
        {
            self.flashingPattern = aDecoder.decodeObjectForKey("flashingPattern") as! FlashingPattern
        }
        if(aDecoder.containsValueForKey("colorSet"))
        {
            self.colorSet = aDecoder.decodeObjectForKey("colorSet") as! [Color]
        }
        if(aDecoder.containsValueForKey("maxColors"))
        {
            self.maxColors = aDecoder.decodeObjectForKey("maxColors") as! Int
        }
        if(aDecoder.containsValueForKey("threshold"))
        {
            self.threshold = aDecoder.decodeObjectForKey("threshold") as! Int
        }
        if(aDecoder.containsValueForKey("colorTints"))
        {
            self.colorTints = aDecoder.decodeObjectForKey("colorTints") as! [String]
        }
        if(aDecoder.containsValueForKey("customFP"))
        {
            self.customFP = aDecoder.decodeObjectForKey("customFP") as! Bool
        }
    }
}

class Palette:NSObject
{
    var name:String = ""
    var colors:[Color] = [] //TODO: Unlimited colors?
    
    init(name:String, colors:[Color])
    {
        self.name = name
        self.colors = colors
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.colors, forKey: "colors")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("name"))
        {
            self.name = aDecoder.decodeObjectForKey("name") as! String
        }
        if(aDecoder.containsValueForKey("colors"))
        {
            self.colors = aDecoder.decodeObjectForKey("colors") as! [Color]
        }
    }
}

class FlashingPattern:NSObject
{
    var name:String = ""
    var imageName:String = ""
    var code:Int = -1
    
    //Custom parameters
    var strobeLength:Int = 15
    var gapLength:Int = 15
    var groupGapLength:Int = 0
    var faderOption:Int = 0
    var faderSpeed:Int = 0
    var brightnessSpeed:Int = 0
    var colorRepeat:Int = 0
    var groupRepeat:Int = 0
    var groupingNumber:Int = 0
    var firstColorStrobeLength:Int = 0
    var firstColorRepeat:Int = 0
    var firstColorPosition:Int = 0
    var rampOption:Int = 0
    var rampTargetLength:Int = 0
    
    init(name:String, imageName:String, code:Int, strobeLength:Int = 15, gapLength:Int = 15, groupGapLength:Int = 0, faderOption:Int = 0, faderSpeed:Int = 0, brightnessSpeed:Int = 0, colorRepeat:Int = 0, groupRepeat:Int = 0, groupingNumber:Int = 0, firstColorStrobeLength:Int = 0, firstColorRepeat:Int = 0, firstColorPosition:Int = 0, rampOption:Int = 0, rampTargetLength:Int = 0)
    {
        self.name = name
        self.imageName = imageName
        self.code = code
        self.strobeLength = strobeLength
        self.gapLength = gapLength
        self.groupGapLength = groupGapLength
        self.faderOption = faderOption
        self.faderSpeed = faderSpeed
        self.brightnessSpeed = brightnessSpeed
        self.colorRepeat = colorRepeat
        self.groupRepeat = groupRepeat
        self.groupingNumber = groupingNumber
        self.firstColorStrobeLength = firstColorStrobeLength
        self.firstColorRepeat = firstColorRepeat
        self.firstColorPosition = firstColorPosition
        self.rampOption = rampOption
        self.rampTargetLength = rampTargetLength
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.imageName, forKey: "imageName")
        aCoder.encodeObject(self.code, forKey: "code")
        aCoder.encodeObject(self.strobeLength, forKey: "colorTime")
        aCoder.encodeObject(self.gapLength, forKey: "blankTime")
        aCoder.encodeObject(self.groupGapLength, forKey: "groupGapLength")
        aCoder.encodeObject(self.faderOption, forKey: "faderOption")
        aCoder.encodeObject(self.faderSpeed, forKey: "faderSpeed")
        aCoder.encodeObject(self.brightnessSpeed, forKey: "brightnessSpeed")
        aCoder.encodeObject(self.colorRepeat, forKey: "colorRepeat")
        aCoder.encodeObject(self.groupRepeat, forKey: "groupRepeat")
        aCoder.encodeObject(self.groupingNumber, forKey: "groupingNumber")
        aCoder.encodeObject(self.firstColorStrobeLength, forKey: "firstColorStrobeLength")
        aCoder.encodeObject(self.firstColorRepeat, forKey: "firstColorRepeat")
        aCoder.encodeObject(self.firstColorPosition, forKey: "firstColorPosition")
        aCoder.encodeObject(self.rampOption, forKey: "rampOption")
        aCoder.encodeObject(self.rampTargetLength, forKey: "rampTargetLength")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("name"))
        {
            self.name = aDecoder.decodeObjectForKey("name") as! String
        }
        if(aDecoder.containsValueForKey("imageName"))
        {
            self.imageName = aDecoder.decodeObjectForKey("imageName") as! String
        }
        if(aDecoder.containsValueForKey("code"))
        {
            self.code = aDecoder.decodeObjectForKey("code") as! Int
        }
        if(aDecoder.containsValueForKey("colorTime"))
        {
            self.strobeLength = aDecoder.decodeObjectForKey("colorTime") as! Int
        }
        if(aDecoder.containsValueForKey("blankTime"))
        {
            self.gapLength = aDecoder.decodeObjectForKey("blankTime") as! Int
        }
        if(aDecoder.containsValueForKey("groupGapLength"))
        {
            self.groupGapLength = aDecoder.decodeObjectForKey("groupGapLength") as! Int
        }
        if(aDecoder.containsValueForKey("faderOption"))
        {
            self.faderOption = aDecoder.decodeObjectForKey("faderOption") as! Int
        }
        if(aDecoder.containsValueForKey("faderSpeed"))
        {
            self.faderSpeed = aDecoder.decodeObjectForKey("faderSpeed") as! Int
        }
        if(aDecoder.containsValueForKey("brightnessSpeed"))
        {
            self.brightnessSpeed = aDecoder.decodeObjectForKey("brightnessSpeed") as! Int
        }
        if(aDecoder.containsValueForKey("colorRepeat"))
        {
            self.colorRepeat = aDecoder.decodeObjectForKey("colorRepeat") as! Int
        }
        if(aDecoder.containsValueForKey("groupRepeat"))
        {
            self.groupRepeat = aDecoder.decodeObjectForKey("groupRepeat") as! Int
        }
        if(aDecoder.containsValueForKey("groupingNumber"))
        {
            self.groupingNumber = aDecoder.decodeObjectForKey("groupingNumber") as! Int
        }
        if(aDecoder.containsValueForKey("firstColorStrobeLength"))
        {
            self.firstColorStrobeLength = aDecoder.decodeObjectForKey("firstColorStrobeLength") as! Int
        }
        if(aDecoder.containsValueForKey("firstColorRepeat"))
        {
            self.firstColorRepeat = aDecoder.decodeObjectForKey("firstColorRepeat") as! Int
        }
        if(aDecoder.containsValueForKey("firstColorPosition"))
        {
            self.firstColorPosition = aDecoder.decodeObjectForKey("firstColorPosition") as! Int
        }
        if(aDecoder.containsValueForKey("rampOption"))
        {
            self.rampOption = aDecoder.decodeObjectForKey("rampOption") as! Int
        }
        if(aDecoder.containsValueForKey("rampTargetLength"))
        {
            self.rampTargetLength = aDecoder.decodeObjectForKey("rampTargetLength") as! Int
        }
    }
}

class Color:NSObject
{
    //RGB 0...255
    var red:Int = -1
    var blue:Int = -1
    var green:Int = -1
    var fixedColorRef:Int = -1 //Only set on stock colors (at initialization)
    var assignedColorRef:Int = -1 //Only set on custom colors (when sent to gloves), cleared before next send
    let colorMax:Int = 255
    var disabled:Bool = false
    //var name:String = ""
    var customColor:UIColor!
    
    init(color:UIColor)
    {
        self.customColor = color
        self.red = Int(self.customColor.components.red * 255)
        self.green = Int(self.customColor.components.green * 255)
        self.blue = Int(self.customColor.components.blue * 255)
    }
    
    init(red:Int, green:Int, blue:Int, colorRef:Int = -1)
    {
        self.red = red
        self.blue = blue
        self.green = green
        /*if(name != "")
        {
            self.name = name
        }*/
        if(colorRef != -1)
        {
            self.fixedColorRef = colorRef
        }
    }
    
    init(disabled:Bool)
    {
        self.disabled = true
        self.red = 0
        self.green = 0
        self.blue = 0
    }
    
    func compareTo(color:Color)->Bool
    {
        return (self.red == color.red && self.blue == color.blue && self.green == color.green && self.disabled == color.disabled)
    }
    
    func copyObject()->Color
    {
        if(customColor != nil)
        {
            return Color(color: customColor)
        }
        else
        {
            return Color(red: self.red, green: self.green, blue: self.blue, colorRef: self.fixedColorRef)
        }
    }
    
    func getUIColor()->UIColor
    {
        if(customColor != nil)
        {
            return customColor
        }
        else
        {
            return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
        }
    }
    
    func getCGColor()->CGColor
    {
        return getUIColor().CGColor
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.red, forKey: "red")
        aCoder.encodeObject(self.green, forKey: "green")
        aCoder.encodeObject(self.blue, forKey: "blue")
        aCoder.encodeObject(self.fixedColorRef, forKey: "fixedColorRef")
        aCoder.encodeObject(self.assignedColorRef, forKey: "assignedColorRef")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("red"))
        {
            self.red = aDecoder.decodeObjectForKey("red") as! Int
        }
        if(aDecoder.containsValueForKey("green"))
        {
            self.green = aDecoder.decodeObjectForKey("green") as! Int
        }
        if(aDecoder.containsValueForKey("blue"))
        {
            self.blue = aDecoder.decodeObjectForKey("blue") as! Int
        }
        if(aDecoder.containsValueForKey("fixedColorRef"))
        {
            self.fixedColorRef = aDecoder.decodeObjectForKey("fixedColorRef") as! Int
        }
        if(aDecoder.containsValueForKey("assignedColorRef"))
        {
            self.assignedColorRef = aDecoder.decodeObjectForKey("assignedColorRef") as! Int
        }
    }
}