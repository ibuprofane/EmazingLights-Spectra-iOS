//
//  Settings.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/23/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation

struct EmazingSettings {
    static var settings:Settings = Settings()
}

class Settings:NSObject
{
    //Stock Data
    var stockGloveSets:[GloveSet] = []
    var stockChips:[Chip] = []
    var stockFlashingPatterns:[FlashingPattern] = []
    var stockModes:[Mode] = []
    var stockPalettes:[Palette] = []
    var stockColors:[Color] = []
    
    //Custom Data
    var customGloveSets:[GloveSet] = []
    var customChips:[Chip] = []
    var customFlashingPatterns:[FlashingPattern] = []
    var customModes:[Mode] = []
    var customPalettes:[Palette] = []
    //var customColors:[Color] = []
    
    var basicStrobeRGBMode:Mode!
    var emptyPalette:Palette!
    
    //Image caching
    var bannerImageCache:[ImageLinkCell] = []
    var homePageImageCache:[ImageLinkCell] = []
    
    //Hardware
    //var activeGloveHub:GloveHub!
    //var registeredHubs:[GloveHub] = []
    var gloveGroups:[GloveGroup] = []
    var photoHubs:[PhotoHub] = []
    
    var settingsVersion:Int = 1
    var patternsVersion:Int = 1
    var colorsVersion:Int = 1
    var timersVersion:Int = 1
    var motionVersion:Int = 1
    
    var lastCheckedFirmwareVersionOnGlove:Int = 0
    var clearSettingsOnStart:Bool = false
    
    override init()
    {
        super.init()
        
        initializeBaseObjects()
    }
    
    func save()
    {
        self.saveCustomObject(self, key: "Settings")
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.settingsVersion, forKey: "settingsVersion")
        aCoder.encodeObject(self.patternsVersion, forKey: "patternsVersion")
        aCoder.encodeObject(self.colorsVersion, forKey: "colorsVersion")
        aCoder.encodeObject(self.timersVersion, forKey: "timersVersion")
        aCoder.encodeObject(self.motionVersion, forKey: "motionVersion")
        aCoder.encodeObject(self.bannerImageCache, forKey: "bannerImageCache")
        aCoder.encodeObject(self.homePageImageCache, forKey: "homePageImageCache")
        aCoder.encodeObject(self.lastCheckedFirmwareVersionOnGlove, forKey: "lastCheckedFirmwareVersionOnHub")
        aCoder.encodeObject(self.photoHubs, forKey: "photoHubs")
        aCoder.encodeObject(self.stockGloveSets, forKey: "stockGloveSets")
        aCoder.encodeObject(self.stockChips, forKey: "stockChips")
        aCoder.encodeObject(self.stockFlashingPatterns, forKey: "stockFlashingPatterns")
        aCoder.encodeObject(self.stockModes, forKey: "stockModes")
        aCoder.encodeObject(self.stockPalettes, forKey: "stockPalettes")
        aCoder.encodeObject(self.stockColors, forKey: "stockColors")
        aCoder.encodeObject(self.customGloveSets, forKey: "customGloveSets")
        aCoder.encodeObject(self.customChips, forKey: "customChips")
        aCoder.encodeObject(self.customModes, forKey: "customModes")
        aCoder.encodeObject(self.customPalettes, forKey: "customPalettes")
        //aCoder.encodeObject(self.customColors, forKey: "customColors")
        aCoder.encodeObject(self.customFlashingPatterns, forKey: "customFlashingPatterns")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()

        initializeBaseObjects()
        
        if(aDecoder.containsValueForKey("settingsVersion"))
        {
            self.settingsVersion = aDecoder.decodeObjectForKey("settingsVersion") as! Int
        }
        if(aDecoder.containsValueForKey("patternsVersion"))
        {
            self.patternsVersion = aDecoder.decodeObjectForKey("patternsVersion") as! Int
        }
        if(aDecoder.containsValueForKey("colorsVersion"))
        {
            self.colorsVersion = aDecoder.decodeObjectForKey("colorsVersion") as! Int
        }
        if(aDecoder.containsValueForKey("timersVersion"))
        {
            self.timersVersion = aDecoder.decodeObjectForKey("timersVersion") as! Int
        }
        if(aDecoder.containsValueForKey("motionVersion"))
        {
            self.motionVersion = aDecoder.decodeObjectForKey("motionVersion") as! Int
        }
        if(aDecoder.containsValueForKey("bannerImageCache"))
        {
            self.bannerImageCache = aDecoder.decodeObjectForKey("bannerImageCache") as! [ImageLinkCell]
        }
        if(aDecoder.containsValueForKey("homePageImageCache"))
        {
            self.homePageImageCache = aDecoder.decodeObjectForKey("homePageImageCache") as! [ImageLinkCell]
        }
        if(aDecoder.containsValueForKey("lastCheckedFirmwareVersionOnHub"))
        {
            self.lastCheckedFirmwareVersionOnGlove = aDecoder.decodeObjectForKey("lastCheckedFirmwareVersionOnHub") as! Int
        }
        if(aDecoder.containsValueForKey("photoHubs"))
        {
            self.photoHubs = aDecoder.decodeObjectForKey("photoHubs") as! [PhotoHub]
        }
        if(aDecoder.containsValueForKey("stockGloveSets"))
        {
            self.stockGloveSets = aDecoder.decodeObjectForKey("stockGloveSets") as! [GloveSet]
        }
        if(aDecoder.containsValueForKey("stockChips"))
        {
            self.stockChips = aDecoder.decodeObjectForKey("stockChips") as! [Chip]
        }
        if(aDecoder.containsValueForKey("stockFlashingPatterns"))
        {
            self.stockFlashingPatterns = aDecoder.decodeObjectForKey("stockFlashingPatterns") as! [FlashingPattern]
        }
        if(aDecoder.containsValueForKey("stockModes"))
        {
            self.stockModes = aDecoder.decodeObjectForKey("stockModes") as! [Mode]
        }
        if(aDecoder.containsValueForKey("stockPalettes"))
        {
            self.stockPalettes = aDecoder.decodeObjectForKey("stockPalettes") as! [Palette]
        }
        if(aDecoder.containsValueForKey("stockColors"))
        {
            self.stockColors = aDecoder.decodeObjectForKey("stockColors") as! [Color]
        }
        if(aDecoder.containsValueForKey("customGloveSets"))
        {
            self.customGloveSets = aDecoder.decodeObjectForKey("customGloveSets") as! [GloveSet]
        }
        if(aDecoder.containsValueForKey("customChips"))
        {
            self.customChips = aDecoder.decodeObjectForKey("customChips") as! [Chip]
        }
        if(aDecoder.containsValueForKey("customModes"))
        {
            self.customModes = aDecoder.decodeObjectForKey("customModes") as! [Mode]
        }
        if(aDecoder.containsValueForKey("customPalettes"))
        {
            self.customPalettes = aDecoder.decodeObjectForKey("customPalettes") as! [Palette]
        }
        /*if(aDecoder.containsValueForKey("customColors"))
        {
            self.customColors = aDecoder.decodeObjectForKey("customColors") as! [Color]
        }*/
        if(aDecoder.containsValueForKey("customFlashingPatterns"))
        {
            self.customFlashingPatterns = aDecoder.decodeObjectForKey("customFlashingPatterns") as! [FlashingPattern]
        }
    }
    
    func saveCustomObject(object:Settings, key:String)
    {
        let encodedObject:NSData = NSKeyedArchiver.archivedDataWithRootObject(object)
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(encodedObject, forKey: key)
        defaults.synchronize()
    }
    
    func loadCustomObjectWithKey(key:String)->Settings
    {
        let defaults:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let encodedObject:NSData = defaults.objectForKey(key) as! NSData
        NSKeyedUnarchiver.setClass(Settings.self, forClassName: "Settings")
        NSKeyedArchiver.setClassName("Settings", forClass: Settings.self)
        let ELSettingsData:Settings = NSKeyedUnarchiver.unarchiveObjectWithData(encodedObject) as! Settings
        return ELSettingsData
    }
    
    func initializeBaseObjects()
    {
        let red = Color(red: 255, green: 0, blue: 0, colorRef: 2)
        let green = Color(red: 0, green: 255, blue: 0, colorRef: 9)
        let blue = Color(red: 0, green: 0, blue: 255, colorRef: 16)
        let strobeFP = FlashingPattern(name: "Strobe", imageName: "1-Strobe", code: 1)
        let strobeSeq = Sequence(flashingPattern: strobeFP, colorSet: [red, green, blue])
        let rgbStrobeMode = Mode(name: "Strobe RGB", sequences: [strobeSeq.copyObject(), strobeSeq.copyObject()])
        self.basicStrobeRGBMode = rgbStrobeMode
        
        let emptyPalette = Palette(name: "Other Palettes", colors: [])
        self.emptyPalette = emptyPalette
    }
}