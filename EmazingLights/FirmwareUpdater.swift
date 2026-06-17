//
//  FirmwareUpdater.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/3/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation
import Parse
import CoreBluetooth

protocol FirmwareStatusDelegate
{
    func firmwareVersionChecked(newFirmwareAvailable:Bool)
}

protocol FirmwareUpdaterDelegate
{
    func downloadingFirmware(status:String)
    func downloadProgress(progress:Float)
    func firmwareDownloadFinished()
    func updatingBLEDevice(status:String)
    func bleUpdateFinished(success:Bool)
}

class FirmwareUpdater
{
    var glovesToUpdate:[Glove] = []
    
    var updaterDelegate:FirmwareUpdaterDelegate?
    var statusDelegate:FirmwareStatusDelegate?
    var commManager:CommManager!
    
    var firmwareVersionReceivedFromGlove:Bool = false
    var gloveFirmwareVersion:Int = 0
    var gloveFirmwareVersionReceivedFromParse:Bool = false
    var parseGloveFirmwareVersion:Int = 2
    
    init(commManager:CommManager)
    {
        self.commManager = commManager
        getLatestGloveFirmwareVersionFromParse()
    }
    
    func beginUpdate(glovesToUpdate:[Glove])
    {
        self.glovesToUpdate = glovesToUpdate
        let deviceTypes:[String] = ["photoHub"]
        downloadFilesFromParse(deviceTypes)
    }
    
    func getLatestGloveFirmwareVersionFromParse()
    {
        let query = PFQuery(className: "Firmware")
        query.findObjectsInBackgroundWithBlock { ( objects:[PFObject]?, error) -> Void in
            if(error == nil && objects != nil)
            {
                for object in objects!
                {
                    let deviceType = object.objectForKey("deviceType") as! String
                    
                    if(deviceType == "photoHub")
                    {
                        let version = object.objectForKey("version") as! Int
                        self.gloveFirmwareVersionReceivedFromParse(version)
                    }
                }
            }
            else
            {
                print(error)
            }
        }
    }
    
    func downloadFilesFromParse(deviceTypes:[String])
    {
        var firmware:[FirmwarePackage] = []
        
        let query = PFQuery(className: "Firmware")
        //query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock { ( objects:[PFObject]?, error) -> Void in
            if(error == nil && objects != nil)
            {
                for object in objects!
                {
                    let deviceType = object.objectForKey("deviceType") as! String
                    
                    for requestedDevice in deviceTypes
                    {
                        if(requestedDevice == deviceType)
                        {
                            let version = object.objectForKey("version") as! Int
                            
                            if(requestedDevice == "photoHub")
                            {
                                self.gloveFirmwareVersionReceivedFromParse(version)
                            }
                            
                            let file:PFFile = object.objectForKey("file") as! PFFile
                            if(!file.isKindOfClass(NSNull))
                            {
                                if let url  = NSURL(string: file.url!)
                                {
                                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                        self.updaterDelegate?.downloadingFirmware("Downloading glove firmware")
                                    }
                                    
                                    if let data = NSData(contentsOfURL: url)
                                    {
                                        firmware.append(FirmwarePackage(deviceType: deviceType, file: data, version: version))
                                    }
                                }
                            }
                            
                            break
                        }
                    }
                }
                
                if(firmware.count > 0)
                {
                    print("Firmware Download - count:\(firmware.count)")
                    
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.updaterDelegate?.firmwareDownloadFinished()
                    }
                    
                    self.doBLEUpdate(firmware)
                }
            }
            else
            {
                print(error)
            }
        }
    }
    
    func doBLEUpdate(firmware:[FirmwarePackage])->Bool
    {
        if(firmware.count > 0)
        {
            for package in firmware
            {
                if(package.deviceType == "photoHub")
                {
                    //TODO: Handle multiple gloves
                    //for glove in glovesToUpdate
                    //{
                        //TODO: Check if peripheral and characteristics are defined
                        commManager.updateFirmware(package.file, hub: EmazingSettings.settings.photoHubs[0])
                    //}
                }
            }
            
            return true
        }
        else
        {
            print("No firmware to update")
            return true
        }
    }
    
    func presentFirmwareUpdateView()
    {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller:StartFirmwareUpdateViewController = storyboard.instantiateViewControllerWithIdentifier("startFirmwareUpdateView") as! StartFirmwareUpdateViewController
        controller.firmwareUpdater = self
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    func firmwareVersionReceivedFromGlove(version:Int)
    {
        firmwareVersionReceivedFromGlove = true
        gloveFirmwareVersion = version
        
        EmazingSettings.settings.lastCheckedFirmwareVersionOnGlove = version
        
        doFirmwareComparison()
    }
    
    func doFirmwareComparison()
    {
        if(firmwareVersionReceivedFromGlove && gloveFirmwareVersionReceivedFromParse)
        {
            if(gloveFirmwareVersion < parseGloveFirmwareVersion)
            {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.statusDelegate?.firmwareVersionChecked(true)
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.statusDelegate?.firmwareVersionChecked(false)
                }
            }
        }
    }
    
    func gloveFirmwareVersionReceivedFromParse(version:Int)
    {
        gloveFirmwareVersionReceivedFromParse = true
        parseGloveFirmwareVersion = version
        
        print("Got glove firmware version from parse: \(version)")
        
        if(EmazingSettings.settings.lastCheckedFirmwareVersionOnGlove < parseGloveFirmwareVersion)
        {
            //Prompt user
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.promptForFirmwareUpdate()
            }
        }
    }
    
    func promptForFirmwareUpdate()
    {
        //TODO: Uncomment this for production
        /*let alertController = UIAlertController(title: "Firmware Update", message: "An update may be available for your gloves. Would you like to check for updates now?", preferredStyle: .Alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) in
            print("Yes pressed")
            self.presentFirmwareUpdateView()
        }
        alertController.addAction(yesAction)
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) in
            print("No pressed")
        }
        alertController.addAction(cancelAction)
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        */
    }
    
    /*func firmwareVersionReceivedFromGlove(version:Int)
    {
    firmwareVersionReceivedFromGlove = true
    gloveFirmwareVersion = version
    
    doFirmwareComparison()
    }*/
    
    
    /*func gloveFirmwareVersionReceivedFromParse(version:Int)
    {
    gloveFirmwareVersionReceivedFromParse = true
    parseGloveFirmwareVersion = version
    
    doFirmwareComparison()
    }*/
}

class FirmwarePackage
{
    var file:NSData!
    var deviceType:String!
    var version:Int!
    
    init(deviceType:String, file:NSData, version:Int)
    {
        self.file = file
        self.deviceType = deviceType
        self.version = version
    }
}