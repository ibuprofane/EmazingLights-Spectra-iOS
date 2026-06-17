//
//  CommManager.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 11/23/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import QuartzCore

struct EmazingCommManager {
    static var commManager:CommManager = CommManager()
}

protocol GlovesConnectionStatusDelegate
{
    func gloveConnectionStatus(status:String)
}

protocol FoundGlovesDelegate
{
    func updateFoundGloves(gloves:[Glove])
}

protocol PhotoHubConnectionStatusDelegate
{
    func photoHubConnectionStatus(status:String)
}

protocol FoundPhotoHubsDelegate
{
    func updateFoundPhotoHubs(hubs:[PhotoHub])
}

class CommManager:NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private let centralQueue = dispatch_queue_create("com.emazinglights.ble.central.main", DISPATCH_QUEUE_SERIAL)
    var initialized:Bool = false
    var connectionState:String = "Disconnected"
    var manager:CBCentralManager!
    var glovesDelegate:FoundGlovesDelegate?
    var photoHubsDelegate:FoundPhotoHubsDelegate?
    var firmwareUpdater:FirmwareUpdater!
    var syncManager:SyncManager!
    var foundGlovesList:[Glove] = []
    var foundPhotoHubsList:[PhotoHub] = []
    var pairingMode:Bool = false
    var bluetoothStatus:CBCentralManagerState = CBCentralManagerState.Unknown
    var connectedGloves:[Glove] = []
    var connectedPhotoHubs:[PhotoHub] = []
    var specifiedUUID:String = ""
    var connectionTimeoutTimer:NSTimer!
    var firmwareUpdateTimer:NSTimer!
    var gloveConnectionStatusDelegate:GlovesConnectionStatusDelegate?
    var photoHubConnectionStatusDelegate:PhotoHubConnectionStatusDelegate?
    var hardwareFilter:String = "bluenrg" //TODO: remove this as default?
    var notifySyncReady:Bool = false
    var notifyPreviewReady:Bool = false
    var forceSyncCancel:Bool = false
    let alwaysAllowPairing:Bool = false

    override init()
    {
        super.init()
        self.manager = CBCentralManager(delegate: self, queue: centralQueue)
        
        //self.manager.delegate = self
        
        self.firmwareUpdater = FirmwareUpdater(commManager: self)
        self.syncManager = SyncManager(commManager: self)
    }
    
    //MARK: - Hardware Connection and Scanning
    
    func scanForHardware(deviceType:String, pairingMode:Bool, uuid:String = "") {
 
        connectionState = "Connecting"
        
        stopHardwareScan()
        usleep(100000)
        
        self.pairingMode = pairingMode
        self.hardwareFilter = deviceType
        
        //Reset found gloves list
        self.foundGlovesList = []
        self.foundPhotoHubsList = []
        self.specifiedUUID = uuid
        
        self.manager.scanForPeripheralsWithServices(nil, options: nil)
        /*let services = [CBUUID(string: EmazingConstants.services.advertisedServiceUUID)]
        let dictionary = NSDictionary(object: NSNumber.init(integer: 1), forKey: CBCentralManagerScanOptionAllowDuplicatesKey)
        self.manager.scanForPeripheralsWithServices(services, options: dictionary as! [String : AnyObject])*/
    }
    
    func stopHardwareScan()
    {
        self.pairingMode = false
        self.manager.stopScan()
        //self.hardwareFilter = ""
    }
    
    func connectionTimedOut()
    {
        stopHardwareScan()
        disconnectFromGloves() //Just in case
        disconnectFromPhotoHubs() //Just in case
        connectionState = "Disconnected"
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.gloveConnectionStatusDelegate?.gloveConnectionStatus("Timed Out")
        }
    }
    
    //MARK: - PhotoHub Connection code
    
    func connectToFoundPhotoHub(photoHub:PhotoHub)
    {
        stopHardwareScan()
        
        self.connectedPhotoHubs.append(photoHub)
        photoHub.peripheral!.delegate = self
        
        self.manager.connectPeripheral(photoHub.peripheral!, options: nil)
    }
    
    func connectToKnownPhotoHub(uuid:String, sync:Bool = false, preview:Bool = false)
    {
        if(connectionState == "Disconnected")
        {
            stopConnectionTimeoutTimer()
            
            print("Connecting to Hub")

            self.connectionTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(CommManager.connectionTimedOut), userInfo: nil, repeats: false)
            self.notifySyncReady = sync
            self.notifyPreviewReady = preview
            self.scanForHardware(EmazingConstants.constants.photoHubHardwareName, pairingMode: false, uuid: uuid)
        }
    }
    
    func disconnectFromPhotoHubs()
    {
        //TODO: Develop disconnect code
        for photoHub in self.connectedPhotoHubs
        {
            print("Disconnecting from active photoHub")
            
            for (_, characteristic) in photoHub.characteristics
            {
                if(characteristic.isNotifying)
                {
                    photoHub.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                }
            }
            
            self.manager.cancelPeripheralConnection(photoHub.peripheral!)
            self.connectedPhotoHubs.removeFirst()
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.photoHubConnectionStatusDelegate?.photoHubConnectionStatus("Disconnected")
            }
        }
        
        connectionState = "Disconnected"
    }
    
    //MARK: - Glove Connection code
    
    func connectToFoundGlove(glove:Glove)
    {
        stopHardwareScan()
        
        self.connectedGloves.append(glove)
        glove.peripheral!.delegate = self
        
        self.manager.connectPeripheral(glove.peripheral!, options: nil)
    }
    
    func connectToKnownGlove(glove:Glove)
    {
        stopConnectionTimeoutTimer()
        self.connectionTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(CommManager.connectionTimedOut), userInfo: nil, repeats: false)
        self.scanForHardware(EmazingConstants.constants.gloveHardwareName, pairingMode: false, uuid: glove.UUID)
    }
    
    func disconnectFromGloves()
    {
        //TODO: Develop disconnect code
        for glove in self.connectedGloves
        {
            print("Disconnecting from active glove")
            
            for (_, characteristic) in glove.characteristics
            {
                if(characteristic.isNotifying)
                {
                    glove.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                }
            }
            
            self.manager.cancelPeripheralConnection(glove.peripheral!)
            self.connectedGloves.removeFirst()
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.gloveConnectionStatusDelegate?.gloveConnectionStatus("Disconnected")
            }
        }
        
        connectionState = "Disconnected"
    }
    
    //MARK: - Write Message
    
    func writeShortMessageToCharacteristic(data:NSData, peripheral:CBPeripheral, characteristic:CBCharacteristic)
    {
        var writeType:CBCharacteristicWriteType
        if ((characteristic.properties.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue) != 0)
        {
            writeType = CBCharacteristicWriteType.WithoutResponse
        }
        else if ((characteristic.properties.rawValue & CBCharacteristicProperties.Write.rawValue) != 0)
        {
            writeType = CBCharacteristicWriteType.WithResponse
        }
        else
        {
            print("writeRawData", "Unable to write data without characteristic write property")
            return
        }
        
        //send data in lengths of <= 20 bytes
        let dataLength = data.length
        let limit = 20
        
        //Below limit, send as-is
        if (dataLength <= limit)
        {
            peripheral.writeValue(data, forCharacteristic: characteristic, type: writeType)
            print("Sent data: \(data.hexStringRepresentation())")
        }
    }
    
    //MARK: - Firmware Updating
    
    func updateFirmware(data:NSData, hub:PhotoHub)
    {
        usleep(2000000)
        
        //TODO: Error checking
        if(hub.peripheral != nil && hub.characteristics.count > 0)
        {
            let newImage = hub.characteristics[EmazingConstants.characteristics.otaNewImage]
            let newImageContent = hub.characteristics[EmazingConstants.characteristics.otaNewImageContent]
            let expectedSequence = hub.characteristics[EmazingConstants.characteristics.otaExpectedSequenceNumber]
            
            
            sendNewImageHeader(data, peripheral: hub.peripheral!, characteristic: newImage!)
            registerForCharacteristicNotifications(hub.peripheral!, characteristic: expectedSequence!)
            setNewImageContent(data, peripheral: hub.peripheral!, characteristic: newImageContent!)
        }
        else
        {
            fatalError("Fatal error: Trying to update firmware with incomplete data.")
        }
    }
    
    func registerForCharacteristicNotifications(peripheral:CBPeripheral, characteristic:CBCharacteristic)
    {
        print("Registering for notifications on: \(characteristic.UUID.UUIDString)")
        peripheral.setNotifyValue(true, forCharacteristic: characteristic)
    }
    
    
    func sendNewImageHeader(data:NSData, peripheral:CBPeripheral, characteristic:CBCharacteristic)
    {
        //Little-endian        0------>Sig
        //-------- file_crc -----   ------ img size -----   ---- img base -------
        //[0x51, 0x06, 0xa9, 0x4c, 0x00, 0xf0, 0x00, 0x00, 0x00, 0x10, 0x01, 0x08]))
        
        let cleanedData = NSMutableData()
        cleanedData.appendData(data)
        
        //Update the header CRC in the case that this file is not a multiple of 16 bytes
        let dataSize = data.length
        let dataMod = dataSize % 16
        var extraBytes = 0
        if(dataMod != 0)
        {
            extraBytes = 16 - dataMod

            //If newBytes < 16, fill with blanks
            for _ in 0..<extraBytes
            {
                cleanedData.appendBytes([0x00] as [UInt8], length: 1)
            }
        }
        
        var crcInt:NSInteger = 0
        let crc32:NSData = NSData(hexString: cleanedData.CRC32())
        crc32.getBytes(&crcInt, length: sizeof(NSInteger))
        
        let size = cleanedData.length
        self.numberOfPackets = size / 16
        
        print("File crc: \(crc32), length:\(size)")
        
        let packet = NSData(bytes: [UInt8((crcInt >> 24) & 0xff), UInt8((crcInt >> 16) & 0xff), UInt8((crcInt >> 8) & 0xff), UInt8(crcInt & 0xff), UInt8(size & 0xff), UInt8((size >> 8) & 0xff), UInt8((size >> 16) & 0xff), UInt8((size >> 24) & 0xff), 0x00, 0x10, 0x01, 0x08] as [UInt8], length: 12)
        
        print("Image header: \(packet)")
        
        peripheral.writeValue(packet, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
    }
    
    var dataToSend:NSData!
    var storedPeripheral:CBPeripheral!
    var storedChar:CBCharacteristic!
    var initialPacketNum:UInt16 = 0
    var numberOfPackets:Int = -1
    
    //Firmware update watchdog
    var lastPacketSent:UInt16 = 0
    var packetSentLastCheck:UInt16 = 0
    
    func setNewImageContent(data:NSData, peripheral:CBPeripheral, characteristic:CBCharacteristic)
    {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.firmwareUpdater.updaterDelegate?.updatingBLEDevice("Updating hub firmware")
        }
        
        self.dataToSend = data
        self.storedPeripheral = peripheral
        self.storedChar = characteristic
        
        self.packetSentLastCheck = 0
        self.lastPacketSent = 0
        self.firmwareUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(CommManager.checkIfLostConnection), userInfo: nil, repeats: true)
    }
    
    func checkIfLostConnection()
    {
        //Progress was made
        if(lastPacketSent > packetSentLastCheck)
        {
            print("Passed watchdog check")
            packetSentLastCheck = lastPacketSent
        }
        else //No progress made - cancel update
        {
            print("Failed watchdog check")
            
            if(firmwareUpdateTimer != nil)
            {
                self.firmwareUpdateTimer.invalidate()
                self.firmwareUpdateTimer = nil
            }
            
            EmazingCommManager.commManager.disconnectFromGloves()
            
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.firmwareUpdater.updaterDelegate?.bleUpdateFinished(false)
            }
            
            dataToSend = nil
        }
    }
    
    func sendPacketWithNumber(packetNumber:UInt16)
    {
        // FRAME: [CRC] [16 bytes data...(File order)....] [0x00] [seq num low] [seq num high]
        // CRC = 0 ^ [1] ^ [2] ... ^ [19]
        if(dataToSend != nil)
        {
            var contentLength = 16
            let location = Int(packetNumber) * contentLength
            
            let dataLength = self.dataToSend.length
            let remainder = dataLength - location
            if remainder <= contentLength {
                contentLength = remainder
            }
            
            if(location < dataLength)
            {
                let range = NSMakeRange(location, contentLength)
                var newBytes = [UInt8](count: contentLength, repeatedValue: 0)
                dataToSend.getBytes(&newBytes, range: range)
                
                let frame = NSMutableData(capacity: 20)
                frame!.appendBytes([0x00] as [UInt8], length: 1)
                frame!.appendBytes(newBytes, length: contentLength)
                //If newBytes < 16, fill with blanks
                let packetCount = newBytes.count
                for _ in packetCount ..< 16
                {
                    frame!.appendBytes([0x00] as [UInt8], length: 1)
                }
                frame!.appendBytes([0x00] as [UInt8], length: 1)
                frame!.appendBytes([b1(packetNumber)], length: 1)
                frame!.appendBytes([b2(packetNumber)], length: 1)
                
                //Change first byte for CRC
                let crcRange:NSRange = NSMakeRange(0, 1)
                var crc:UInt8 = 0
                for i in 0 ..< newBytes.count
                {
                    crc = crc ^ newBytes[i]
                }
                crc = crc ^ b1(packetNumber) ^ b2(packetNumber)
                frame!.replaceBytesInRange(crcRange, withBytes: [crc])
                
                print("\(self.classForCoder.description()) writeRawData : packet_\(packetNumber) : \(frame!.hexStringRepresentation())")
                
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.firmwareUpdater.updaterDelegate?.downloadProgress(Float(packetNumber) / Float(self.numberOfPackets))
                }
                
                self.storedPeripheral.writeValue(frame!, forCharacteristic: self.storedChar, type: CBCharacteristicWriteType.WithoutResponse)
                
                self.lastPacketSent = packetNumber
            }
            else
            {
                //Firmware update complete
                
                if(firmwareUpdateTimer != nil)
                {
                    self.firmwareUpdateTimer.invalidate()
                    self.firmwareUpdateTimer = nil
                }
                
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    self.firmwareUpdater.updaterDelegate?.bleUpdateFinished(true)
                }
                
                dataToSend = nil
            }
        }
        else
        {
            initialPacketNum = packetNumber
        }
    }
    
    // Converts a UInt16 to 2 little-endian bytes
    func b1(n:UInt16) -> UInt8 { return UInt8(n & 0xFF) }
    func b2(n:UInt16) -> UInt8 { return UInt8((n>>8) & 0xFF) }
    
    //MARK: - CBCentralManagerDelegate
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if(characteristic.value != nil)
        {
            let updatedValue:NSData = characteristic.value!
            let hexString:String = updatedValue.hexStringRepresentation()
            
            //print("Value for \(characteristic.UUID) on \(peripheral.identifier.UUIDString): \(hexString)")
            
            //Update the characteristic
            //connectedGloveHub.characteristics[characteristic.UUID.UUIDString] = characteristic
            
            switch characteristic.UUID.UUIDString
            {
                //Hub status service
            
           /* case EmazingConstants.characteristics.hubBatteryLevel:
                
                connectedGloveHub.decodeBatteryLevel(characteristic.value!)
                
                //TODO: Remove this hack - this uses the battery level characteristic to do a firmware update
                firmwareUpdater.firmwareVersionReceivedFromHub(0)
                */
            case EmazingConstants.characteristics.firmwareVersion:
                firmwareUpdater.firmwareVersionReceivedFromGlove(Int(hexString, radix: 16)!)
                
            /*
                //Hub Command Service
                
            case EmazingConstants.characteristics.hubResponse:
                connectedGloveHub.decodeHubResponse(characteristic.value!)
                
            case EmazingConstants.characteristics.hubState:
                connectedGloveHub.decodeHubState(characteristic.value!)
                
            case EmazingConstants.characteristics.hubScanID:
                connectedGloveHub.decodeHubScanID(characteristic.value!)
                
                
                //Glove Service
                
            case EmazingConstants.characteristics.gloveID:
                connectedGloveHub.decodeGloveID(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveBatteryLevel:
                connectedGloveHub.decodeGloveBatteryLevel(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveName:
                connectedGloveHub.decodeNameOfGlove(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveProgram:
                connectedGloveHub.decodeNameOfGloveProgram(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveFirmwareVersion:
                connectedGloveHub.decodeGloveFirmwareVersion(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveNumberOfModeSlots:
                connectedGloveHub.decodeNumberOfModeSlots(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveSlotFlashingPattern:
                connectedGloveHub.decodeFlashingPatterns(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveSlotColors:
                connectedGloveHub.decodeColors(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveSlotMotion:
                connectedGloveHub.decodeMotionFunctions(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveSensitivity:
                connectedGloveHub.decodeSensitivityTimerSettings(characteristic.value!)
                
            case EmazingConstants.characteristics.gloveError:
                connectedGloveHub.decodeGeneralError(characteristic.value!)
                */
                
                //OTA Service
                
            case EmazingConstants.characteristics.otaExpectedSequenceNumber:
                let indexRange:NSRange = NSMakeRange(0, 2)
                let indexData = updatedValue.subdataWithRange(indexRange)
                var index:UInt16 = 0
                indexData.getBytes(&index, length: sizeof(UInt16))
                
                let errorRange:NSRange = NSRange(location: 2, length: 2)
                let errorData = updatedValue.subdataWithRange(errorRange)
                var error:UInt16 = 0
                errorData.getBytes(&error, length: sizeof(UInt16))
                
                //TODO: Do something if these errors happen?
                if(error != 0)
                {
                    if(error == 255)
                    {
                        print("Error 0xFF - Flash write error")
                        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                            self.firmwareUpdater.updaterDelegate?.bleUpdateFinished(false)
                        }
                    }
                    else if(error == 240)
                    {
                        print("Error 0xF0 - Sequence error, retrying sequence \(index)")
                    }
                    else  if(error == 15)
                    {
                        print("Error 0x0F - Checksum error, retrying sequence \(index)")
                    }
                    else  if(error == 60)
                    {
                        print("Error 0x3C - Flash verification error on sequence \(index)")
                    }
                }
                print("OTA Sequence Requested: \(index)")

                self.sendPacketWithNumber(index)
            default:
                break
                //connectedGloveHub.characteristics[characteristic.UUID.UUIDString] = characteristic
                
            }
        }
    }
    
    func stopConnectionTimeoutTimer()
    {
        print("Reset timeout timer")
        if(connectionTimeoutTimer != nil)
        {
            connectionTimeoutTimer.invalidate()
            connectionTimeoutTimer = nil
        }
    }

    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral){
        
        print("Did connect to: \(peripheral.name)")
        
        connectionState = "Connected"
        
        stopConnectionTimeoutTimer()
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.gloveConnectionStatusDelegate?.gloveConnectionStatus("Connected")
        }
        
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        connectionState = "Disconnected"
        
        stopConnectionTimeoutTimer()
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.gloveConnectionStatusDelegate?.gloveConnectionStatus("Disconnected")
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?)
    {
        print("didFailToConnectPeripheral: \(error)")
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber)
    {
        print("Found a device: \(peripheral.name)")
        
        if(peripheral.name != nil)
        {
            //TODO: Remove "Gub"
            /*if(peripheral.name == self.hardwareFilter && peripheral.name == EmazingConstants.constants.gloveHardwareName)
            {
                //
                // NOTE!!!
                //
                // THIS SECTION IS FOR THE GLOVE CONNECTIONS - PHOTOHUB SECTION IS BELOW
                //
                //
                if(pairingMode)
                {
                    let hubData = parseAdvertisingData(advertisementData)
                    if(hubData.pairingMode)
                    {
                        let foundGlove:Glove = Glove(peripheral: peripheral, name: hubData.name)
                        if(!self.foundGlovesList.contains(foundGlove))
                        {
                            self.foundGlovesList.append(foundGlove)
                            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                self.glovesDelegate?.updateFoundGloves(self.foundGlovesList)
                            }
                        }
                    }
                }
                else
                {
                    if(peripheral.identifier.UUIDString == self.specifiedUUID)
                    {
                        for gloveGroup in EmazingSettings.settings.gloveGroups
                        {
                            for glove in gloveGroup.gloves
                            {
                                glove.peripheral = peripheral
                                self.connectToFoundGlove(glove)
                            }
                        }
                    }
                }
            }
            else if(peripheral.name == self.hardwareFilter && peripheral.name == EmazingConstants.constants.photoHubHardwareName || peripheral.name == "PhotoHub")
            {*/
                if(pairingMode)
                {
                    let hubData = parseAdvertisingData(advertisementData)
                    if(hubData != nil)
                    {
                        if(hubData!.pairingMode)
                        {
                            var matchFound = false
                            for index in 0..<self.foundPhotoHubsList.count
                            {
                                if(self.foundPhotoHubsList[index].UUID == peripheral.identifier.UUIDString)
                                {
                                    matchFound = true
                                    break
                                }
                            }
                            if(!matchFound)
                            {
                                let foundPhotoHub:PhotoHub = PhotoHub(peripheral: peripheral, name: hubData!.name)
                                self.foundPhotoHubsList.append(foundPhotoHub)
                                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                                    self.photoHubsDelegate?.updateFoundPhotoHubs(self.foundPhotoHubsList)
                                }
                            }
                            
                            /*if(!self.foundPhotoHubsList.contains(foundPhotoHub))
                            {
                                
                            }*/
                        }
                    }
                }
                else
                {
                    if(peripheral.identifier.UUIDString == self.specifiedUUID)
                    {
                        for photoHub in EmazingSettings.settings.photoHubs
                        {
                            photoHub.peripheral = peripheral
                            self.connectToFoundPhotoHub(photoHub)
                        }
                    }
                }
            // }
        }
    }
    
    let hubAdvertisingID:String = "<454c4855 4231"
    let pairingStr:String = "01>"
    func parseAdvertisingData(advertisementData: [String : AnyObject])->(name: String, pairingMode: Bool)?
    {
        var deviceInPairingMode:Bool = false
        var localName:String = "Emazing Device"
        var emazingDeviceFound:Bool = false
        for (key, value) in advertisementData
        {
            if(key == "kCBAdvDataManufacturerData")
            {
                let valstring = "\(value)"
                if(valstring.hasPrefix(hubAdvertisingID))
                {
                    emazingDeviceFound = true
                    
                    if(valstring.hasSuffix(pairingStr))
                    {
                        print("Hub found in pairing mode")
                        deviceInPairingMode = true
                    }
                }
            }
            else if(key == "kCBAdvDataLocalName")
            {
                let name = "\(value)"
                localName = name //String(name.characters.dropFirst(1))
            }
        }
        
        if(emazingDeviceFound)
        {
            return (localName, deviceInPairingMode)
        }
        return nil
    }

    func centralManagerDidUpdateState(central: CBCentralManager) {
        if(central.state == CBCentralManagerState.Unsupported)
        {
            print("Bluetooth Low-Energy not supported from simulator. Must test using iPhone hardware.")
        }
        else if(central.state == CBCentralManagerState.PoweredOn)
        {
            print("Bluetooth is now powered on")
            
            //If in pairing mode and Bluetooth is turned on, start scan
            if(pairingMode && self.bluetoothStatus != CBCentralManagerState.PoweredOn)
            {
                self.manager.scanForPeripheralsWithServices(nil, options: nil)
                
                /*let services = [CBUUID(string: EmazingConstants.services.advertisedServiceUUID)]
                let dictionary = NSDictionary(object: NSNumber.init(integer: 1), forKey: CBCentralManagerScanOptionAllowDuplicatesKey)
                self.manager.scanForPeripheralsWithServices(services, options: dictionary as! [String : AnyObject])*/
            }
        }
        else
        {
            print("Bluetooth state changed: \(central.state.rawValue)")
        }
        self.bluetoothStatus = central.state
    }
    
    //MARK: CBPeripheralDelegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if(peripheral.services != nil)
        {
            for service in peripheral.services!
            {
                let cbservice:CBService = service
                print("Found service on \(peripheral.identifier.UUIDString): \(cbservice.UUID.UUIDString)")
                peripheral.discoverCharacteristics(nil, forService: cbservice)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("Got didDiscoverCharacteristicsForService: \(service.UUID)")
        
        if(peripheral.services != nil)
        {
            for characteristic in service.characteristics!
            {
                if(peripheral.name == self.hardwareFilter && peripheral.name == EmazingConstants.constants.photoHubHardwareName)
                {
                    var photoHub:PhotoHub!
                    for eachPhotoHub in self.connectedPhotoHubs
                    {
                        if(eachPhotoHub.peripheral!.identifier.UUIDString == peripheral.identifier.UUIDString)
                        {
                            photoHub = eachPhotoHub
                            break
                        }
                    }
                    if(photoHub != nil)
                    {
                        photoHub.services[service.UUID.UUIDString] = service
                        photoHub.characteristics[characteristic.UUID.UUIDString] = characteristic
                        
                        //TODO: Set this to the last characteristic that will be received
                        if(characteristic.UUID.UUIDString == EmazingConstants.characteristics.gloveState)
                        {
                            if(!forceSyncCancel)
                            {
                                if(self.notifySyncReady)
                                {
                                    self.syncManager.performSync(photoHub)
                                }
                                if(self.notifyPreviewReady)
                                {
                                    self.syncManager.previewReady(photoHub)
                                }
                            }
                            else
                            {
                                forceSyncCancel = false
                                disconnectFromPhotoHubs()
                            }
                        }
                        /*else if(characteristic.UUID.UUIDString == EmazingConstants.characteristics.hubResponse || characteristic.UUID.UUIDString == EmazingConstants.characteristics.hubScanID)
                        {
                        self.registerForCharacteristicNotifications(peripheral, characteristic: characteristic)
                        }*/
                        
                        if ((characteristic.properties.rawValue & CBCharacteristicProperties.Read.rawValue) != 0)
                        {
                            peripheral.readValueForCharacteristic(characteristic)
                            //print("Found characteristic: \(characteristic.UUID), value=\(characteristic.value)")
                        }
                        else
                        {
                            //print("Found write-only characteristic: \(characteristic.UUID)")//, value=\(char.value)")
                        }
                    }
                }
                else
                {
                    var glove:Glove!
                    for eachGlove in self.connectedGloves
                    {
                        if(eachGlove.peripheral!.identifier.UUIDString == peripheral.identifier.UUIDString)
                        {
                            glove = eachGlove
                            break
                        }
                    }
                    if(glove != nil)
                    {
                        glove.services[service.UUID.UUIDString] = service
                        glove.characteristics[characteristic.UUID.UUIDString] = characteristic
                        
                        //TODO: Set this to the last characteristic that will be received
                        if(characteristic.UUID.UUIDString == EmazingConstants.characteristics.slotStatus)
                        {
                            if(self.notifySyncReady)
                            {
                                //TODO: Implement for Glove
                                //self.syncManager.performSync()
                            }
                        }
                        /*else if(characteristic.UUID.UUIDString == EmazingConstants.characteristics.hubResponse || characteristic.UUID.UUIDString == EmazingConstants.characteristics.hubScanID)
                        {
                            self.registerForCharacteristicNotifications(peripheral, characteristic: characteristic)
                        }*/
                        
                        if ((characteristic.properties.rawValue & CBCharacteristicProperties.Read.rawValue) != 0)
                        {
                            peripheral.readValueForCharacteristic(characteristic)
                            print("Found characteristic: \(characteristic.UUID), value=\(characteristic.value)")
                        }
                        else
                        {
                            print("Found write-only characteristic: \(characteristic.UUID)")//, value=\(char.value)")
                        }
                    }
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("Updated notification state for characteristic: \(characteristic.UUID)")
    }
    
    /*func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("Updated value for descriptor: \(descriptor.UUID)")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("Wrote value for descriptor: \(descriptor.UUID)")
    }*/
    
    //This might not be needed
    /*func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error != nil {
            print("descriptorError: \(error.debugDescription)")
        }
            
        else {
            if characteristic.descriptors?.count != 0 {
                for d in characteristic.descriptors! {
                    let desc = d as CBDescriptor!
                    print("Descriptor for \(characteristic.UUID): \(desc.description)")
                }
            }
        }
    }*/
}

