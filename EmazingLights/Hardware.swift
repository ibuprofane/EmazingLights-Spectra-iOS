//
//  Hardware.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/2/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol DeviceUpdateDelegate
{
    func batteryUpdated(value:Int)
}

class Glove:EmazingBLEDevice
{
    override init(peripheral:CBPeripheral, name:String = "EmazingBlue")
    {
        super.init(peripheral: peripheral, name: name)
        self.deviceType = EmazingConstants.constants.gloveHardwareName
    }
    
    override init(uuid:String, name:String)
    {
        super.init(uuid: uuid, name: name)
        self.deviceType = EmazingConstants.constants.gloveHardwareName
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class PhotoHub:EmazingBLEDevice
{
    override init(peripheral:CBPeripheral, name:String = "PhotoHub")
    {
        super.init(peripheral: peripheral, name: name)
        self.deviceType = EmazingConstants.constants.photoHubHardwareName
    }
    
    override init(uuid:String, name:String)
    {
        super.init(uuid: uuid, name: name)
        self.deviceType = EmazingConstants.constants.photoHubHardwareName
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EmazingBLEDevice:NSObject
{
    var UUID:String = ""
    var peripheral:CBPeripheral?
    var services:[String:CBService] = [:]
    var characteristics:[String:CBCharacteristic] = [:]
    var givenName:String = ""
    var batteryLevel:Int = 0
    var delegate:DeviceUpdateDelegate?
    var deviceType:String = ""
    
    init(peripheral:CBPeripheral, name:String = "EmazingBlue")
    {
        self.peripheral = peripheral
        self.givenName = name
        self.UUID = peripheral.identifier.UUIDString
    }
    
    init(uuid:String, name:String)
    {
        self.UUID = uuid
        self.givenName = name
    }
    
    func decodeBatteryLevel(data:NSData)
    {
        self.batteryLevel = getIntegerFromData(data)
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.delegate?.batteryUpdated(self.batteryLevel)
        }
    }
    
    func decodeHubResponse(data:NSData)
    {
        let hubResponse = getIntegerFromData(data)
    }
    
    func decodeHubState(data:NSData)
    {
        let hubState = getIntegerFromData(data)
    }
    
    func decodeHubScanID(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }

    func decodeGloveID(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeGloveBatteryLevel(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeNameOfGlove(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeNameOfGloveProgram(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeGloveFirmwareVersion(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeNumberOfModeSlots(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeFlashingPatterns(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeColors(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeMotionFunctions(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeSensitivityTimerSettings(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func decodeGeneralError(data:NSData)
    {
        let scanID = getIntegerFromData(data)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.UUID, forKey: "UUID")
        aCoder.encodeObject(self.givenName, forKey: "givenName")
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        
        if(aDecoder.containsValueForKey("UUID"))
        {
            self.UUID = aDecoder.decodeObjectForKey("UUID") as! String
        }
        if(aDecoder.containsValueForKey("givenName"))
        {
            self.givenName = aDecoder.decodeObjectForKey("givenName") as! String
        }
    }
    
    func getIntegerFromData(data:NSData)->Int
    {
        var out:NSInteger = 0
        data.getBytes(&out, length: sizeof(NSInteger))
        return Int(out)
    }
}

extension EmazingBLEDevice {
    override var hashValue: Int {
        return UUID.hashValue ^ deviceType.hashValue
    }
}

func ==(lhs: EmazingBLEDevice, rhs: EmazingBLEDevice) -> Bool {
    return lhs.deviceType == rhs.deviceType && lhs.UUID == rhs.UUID
}

class GloveGroup:NSObject
{
    var groupName:String = "My Emazing Gloves"
    var charm:String = ""
    var gloves:[Glove] = []
}