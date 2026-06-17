//
//  SyncManager.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/17/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol SyncManagerDelegate
{
    func syncFinished(completed:Bool)
}

class SyncManager
{
    var commManager:CommManager!
    var payload:[BLECommand]
    var delegate:SyncManagerDelegate?
    var photoHub:PhotoHub?
    var connectionTimeoutTimer:NSTimer!
    
    let previewModeSlot:Int = 0
    let previewModeSequenceSlot:Int = 1
    var previewModeEnabled:Bool = false
    let previewModeTimeout:Double = 30.0
    
    let runModeDisplay:Int = 1
    let runModePhoto:Int = 2
    let runModeColor:Int = 3
    
    let mediumTint:Double = 0.80
    let lowTint:Double = 0.95
    
    let customFPStartIndex = 48
    var customFPIndex = 48
    
    init(commManager:CommManager)
    {
        self.commManager = commManager
        self.payload = []
    }
    
    func prepareForSync(chip:Chip, uuid:String)
    {
        self.payload = generateFullChipSync(chip)
        self.postProcessingCompleted = false
        commManager.connectToKnownPhotoHub(uuid, sync: true)
    }
    
    var postProcessingCompleted:Bool = false
    func performSync(photoHub:PhotoHub)
    {
        //var commandCount = 0 //Used for testing only
        if(payload.count > 0)
        {
            for command in self.payload
            {
                self.commManager.writeShortMessageToCharacteristic(command.dataToSend, peripheral: photoHub.peripheral!, characteristic: photoHub.characteristics[command.characteristic]!)
                usleep(50000)
                //commandCount += 1
                
                /*if(commandCount > 3)
                {
                    commManager.disconnectFromPhotoHubs()
                    commandCount = 0
                    break
                }*/
            }
        }
        
        print("Done chip syncing")
        
        /*if(!postProcessingCompleted)
        {
            usleep(200000)
            postProcessingCompleted = true
            
            var postPayload:[BLECommand] = []

            let initialPostSyncSlot = 1
            let initialPostSyncSequence = 1
            postPayload.append(changeDisplayMode(initialPostSyncSlot, sequenceNum: initialPostSyncSequence))
            postPayload.append(changeRunMode(runModeDisplay))
            payload = []
            performSyncUsingDefaultHub(postPayload)
        }
        else// if(postProcessingCompleted)
        {*/
            print("Done post chip syncing")
            EmazingCommManager.commManager.notifySyncReady = false
            payload = []
            delegate?.syncFinished(true)
        //}
    }
    
    func performSyncUsingDefaultHub(payload:[BLECommand])
    {
        if(!previewModeEnabled || photoHub == nil)
        {
            enablePreviewMode()
            self.payload.appendContentsOf(payload)
            commManager.notifyPreviewReady = true
        }
        else
        {
            self.payload.appendContentsOf(payload)
            
            stopConnectionTimeoutTimer()
            restartConnectionTimeoutTimer()
            performSync(photoHub!)
        }
    }
    
    func setHubNameAndExitPairingMode(uuid:String, name:String)
    {
        commManager.stopHardwareScan()
        commManager.disconnectFromPhotoHubs() //Just in case
        usleep(100000)
        
        self.payload = [writeSetHubName(name), writeExitPairingMode()]
        self.postProcessingCompleted = false
        commManager.connectToKnownPhotoHub(uuid, sync: true)
    }
    
    func turnOffPreview()
    {
        if(previewModeEnabled)
        {
            enableCustomColorPreviewMode()
            previewCustomColor(Color(red: 0, green: 0, blue: 0))
            
            performSyncUsingDefaultHub(payload)
            
            commManager.disconnectFromPhotoHubs()
            previewModeEnabled = false
            photoHub = nil
        }
    }
    
    func enablePreviewMode()
    {
        EmazingCommManager.commManager.forceSyncCancel = false
        
        if(EmazingSettings.settings.photoHubs.count > 0 && !previewModeEnabled)
        {
            commManager.connectToKnownPhotoHub(EmazingSettings.settings.photoHubs[0].UUID, preview: true)
            stopConnectionTimeoutTimer()
            restartConnectionTimeoutTimer()
        }
    }
    
    func previewReady(photoHub:PhotoHub)
    {
        self.photoHub = photoHub
        self.previewModeEnabled = true
        
        if(self.payload.count > 0)
        {
            performSync(photoHub)
        }
    }
    
    func restartConnectionTimeoutTimer()
    {
        self.connectionTimeoutTimer = NSTimer(timeInterval: previewModeTimeout, target: self, selector: #selector(SyncManager.connectionTimedOut), userInfo: nil, repeats: false)
        NSRunLoop.mainRunLoop().addTimer(connectionTimeoutTimer, forMode: NSRunLoopCommonModes)
    }
    
    @objc func connectionTimedOut()
    {
        print("Connection watchdog failed - if this was unexpected, increase timer value")
        stopConnectionTimeoutTimer()
        
        commManager.disconnectFromPhotoHubs()
        previewModeEnabled = false
        photoHub = nil
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
    
    //MARK: Create payloads
    
    func generateFullChipSync(chip:Chip)->[BLECommand]
    {
        self.customFPIndex = customFPStartIndex //Reset
        
        var payload:[BLECommand] = []
        let finger = chip.finger
        var activeModeIndex:Int = 0
        
        for index in 0..<finger.modes.count
        {
            var indexedMode = finger.modes[index]
            if let mode = finger.otfModes[index]
            {
                indexedMode = mode
            }
            
            //If the mode is not disabled, add it to the current chip
            if(finger.disabledModes[index] == false)
            {
                activeModeIndex += 1
                payload.appendContentsOf(writeModeAndBlockForMode(indexedMode, modeIndex: activeModeIndex))
            }
        }
        
        payload.append(changeRunMode(runModeDisplay, availableModes: activeModeIndex))
        
        return payload
    }
    
    func writeModeAndBlockForMode(mode:Mode, modeIndex:Int)->[BLECommand]
    {
        var payload:[BLECommand] = []
        for sequenceNum in 0...1
        {
            let numColors = mode.sequences[sequenceNum].colorSet.count
            let seq = mode.sequences[sequenceNum]
            let fp = seq.flashingPattern
            var fpCode = fp.code
            if(seq.customFP && customFPIndex <= customFPStartIndex + 3) //HACK: //TODO: Remove code preventing more than 4 custom FPs
            {
                fpCode = customFPIndex
                
                //#7
                payload.append(writeFlashingPatternSettings(fpCode, strobeLength: fp.strobeLength, gapLength: fp.gapLength, groupGapLength: fp.groupGapLength, brightnessSpeed: fp.brightnessSpeed, faderValue: fp.faderSpeed, colorRepeat: fp.colorRepeat, groupRepeat: fp.groupRepeat, groupingNumber: fp.groupingNumber, firstColorStrobeLength: fp.firstColorStrobeLength, firstColorRepeat: fp.firstColorRepeat, firstColorPosition: fp.firstColorPosition, rampTargetLength: fp.rampTargetLength))
                customFPIndex += 1
            }
            
            payload.append(writeModeSettings(modeIndex, numColors: numColors, flashingPatternId: fpCode, blankTime: 0, motionType: mode.emotionEffect, sequenceId: sequenceNum + 1, motionThreshold: mode.emotionSpeedOption, motionParam1: mode.emotionParam1, motionParam2: mode.emotionParam2, motionParam3: mode.emotionParam3))
            
            for blockIndex in 0..<numColors
            {
                let components = getComponentColors(mode.sequences[sequenceNum], colorSlot: blockIndex)
                
                payload.append(writeBlockSettings(modeIndex, blockNumber: blockIndex + 1, red: components.red, green: components.green, blue: components.blue, displayTimeMs: 0, sequenceNum: sequenceNum + 1))
            }
        }
        
        return payload
    }
    
    func previewSequence(sequence:Sequence)
    {
        var payload:[BLECommand] = []

        let numColors = sequence.colorSet.count
        let fp = sequence.flashingPattern
        var fpCode = fp.code
        if(sequence.customFP)
        {
            fpCode = customFPStartIndex //customFPIndex
        }
        
        payload.append(writeModeSettings(previewModeSlot, numColors: numColors, flashingPatternId: fpCode, blankTime: 0, motionType: 0, sequenceId: previewModeSequenceSlot, motionThreshold: 0, motionParam1: 0, motionParam2: 0, motionParam3: 0))
        
        for blockIndex in 0..<numColors
        {
            let components = getComponentColors(sequence, colorSlot: blockIndex)
            
            payload.append(writeBlockSettings(previewModeSlot, blockNumber: blockIndex + 1, red: components.red, green: components.green, blue: components.blue, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot))
        }
        
        if(sequence.customFP)
        {
            //#7
            payload.append(writeFlashingPatternSettings(fpCode, strobeLength: fp.strobeLength, gapLength: fp.gapLength, groupGapLength: fp.groupGapLength, brightnessSpeed: fp.brightnessSpeed, faderValue: fp.faderSpeed, colorRepeat: fp.colorRepeat, groupRepeat: fp.groupRepeat, groupingNumber: fp.groupingNumber, firstColorStrobeLength: fp.firstColorStrobeLength, firstColorRepeat: fp.firstColorRepeat, firstColorPosition: fp.firstColorPosition, rampTargetLength: fp.rampTargetLength))
        }
        
        payload.append(changeDisplayMode(previewModeSlot, sequenceNum: previewModeSequenceSlot))
        payload.append(changeRunMode(runModeDisplay))

        performSyncUsingDefaultHub(payload)
    }
    
    func prepareFPPreview(fpID:Int)
    {
        var payload:[BLECommand] = []
        let numColors = 3
        
        //#1
        payload.append(writeModeSettings(previewModeSlot, numColors: numColors, flashingPatternId: fpID, blankTime: 0, motionType: 0, sequenceId: previewModeSequenceSlot, motionThreshold: 0, motionParam1: 0, motionParam2: 0, motionParam3: 0))
        
        //#2
        payload.append(writeBlockSettings(previewModeSlot, blockNumber: 1, red: 255, green: 0, blue: 0, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot))
        payload.append(writeBlockSettings(previewModeSlot, blockNumber: 2, red: 0, green: 255, blue: 0, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot))
        payload.append(writeBlockSettings(previewModeSlot, blockNumber: 3, red: 0, green: 0, blue: 255, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot))
        
        //#3
        payload.append(changeDisplayMode(previewModeSlot, sequenceNum: previewModeSequenceSlot))
        
        //#4
        payload.append(changeRunMode(runModeDisplay))
        
        /*let numColors = sequence.colorSet.count
         payload.append(writeModeSettings(previewModeSlot, numColors: numColors, flashingPatternId: sequence.flashingPattern.code, blankTime: 0, motionType: 0, sequenceId: previewModeSequenceSlot))
         
         for blockIndex in 0..<numColors
         {
         let components = getComponentColors(sequence, colorSlot: blockIndex)
         
         payload.append(writeBlockSettings(previewModeSlot, blockNumber: blockIndex + 1, red: components.red, green: components.green, blue: components.blue, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot))
         }
         
         payload.append(changeDisplayMode(previewModeSlot, sequenceNum: previewModeSequenceSlot))
         payload.append(changeRunMode(runModeDisplay))
         */
        performSyncUsingDefaultHub(payload)
    }
    
    func previewCustomFlashingPattern(patternNumber:Int, strobeLength:Int, gapLength:Int, groupGapLength:Int, brightnessSpeed:Int, faderValue:Int, colorRepeat:Int, groupRepeat:Int, groupingNumber:Int, firstColorStrobeLength:Int, firstColorRepeat:Int, firstColorPosition:Int, rampTargetLength:Int)
    {
        var payload:[BLECommand] = []
        
        //#7
        payload.append(writeFlashingPatternSettings(patternNumber, strobeLength: strobeLength, gapLength: gapLength, groupGapLength: groupGapLength, brightnessSpeed: brightnessSpeed, faderValue: faderValue, colorRepeat: colorRepeat, groupRepeat: groupRepeat, groupingNumber: groupingNumber, firstColorStrobeLength: firstColorStrobeLength, firstColorRepeat: firstColorRepeat, firstColorPosition: firstColorPosition, rampTargetLength: rampTargetLength))
        
        performSyncUsingDefaultHub(payload)
    }
    
    func enableCustomColorPreviewMode()
    {
        var payload:[BLECommand] = []
        payload.append(changeRunMode(runModeColor))
        performSyncUsingDefaultHub(payload)
    }
    
    func previewCustomColor(color:Color)
    {
        var payload:[BLECommand] = []
        payload.append(setPWMColor(previewModeSlot, red: color.red, green: color.green, blue: color.blue))
        performSyncUsingDefaultHub(payload)
        
        //Chroma method
        //let customColorSequence = Sequence(flashingPattern: FlashingPattern(name: "Chroma", imageName: "7-Chroma", code: 7), colorSet: [color, color, color, color, color, color, color])
        //previewSequence(customColorSequence)
    }
    
    func updatePreviewColorSlot(slot:Int, color:Color, tint:String)
    {
        var payload:[BLECommand] = []
        
        let components = getComponentColors(color, tint: tint)
        
        payload.append(writeBlockSettings(previewModeSlot, blockNumber: slot + 1, red: components.red, green: components.green, blue: components.blue, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot))
        payload.append(changeDisplayMode(previewModeSlot, sequenceNum: previewModeSequenceSlot))
        //payload.append(changeRunMode(runModeDisplay))
        
        performSyncUsingDefaultHub(payload)
    }
    
    func getComponentColors(color:Color, tint:String)->(red:Int, green:Int, blue:Int)
    {
        let configColor = color
        var tintedColor = configColor.getUIColor()
        if(tint == "M")
        {
            tintedColor = tintedColor.darkerColor(mediumTint)
        }
        else if(tint == "L")
        {
            tintedColor = tintedColor.darkerColor(lowTint)
        }
        
        let red = Int(tintedColor.components.red * 255.0)
        let green = Int(tintedColor.components.green * 255.0)
        let blue = Int(tintedColor.components.blue * 255.0)
        
        return (red, green, blue)
    }
    
    func getComponentColors(sequence:Sequence, colorSlot:Int)->(red:Int, green:Int, blue:Int)
    {
        return getComponentColors(sequence.colorSet[colorSlot], tint: sequence.colorTints[colorSlot])
    }
    
    //MARK: - Format Data
    
    func writeModeSettings(mode:Int, numColors:Int, flashingPatternId:Int, blankTime:Int, motionType:Int, sequenceId:Int, motionThreshold:Int, motionParam1:Int, motionParam2:Int, motionParam3:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 1
        let cmd2:UInt8 = UInt8(mode)
        var data = [UInt8]()
        data.append(UInt8(numColors))
        data.append(UInt8(flashingPatternId))
        data.append(UInt8(blankTime))
        data.append(UInt8(motionType))
        data.append(UInt8(sequenceId))
        data.append(UInt8(motionThreshold))
        data.append(UInt8(motionParam1))
        data.append(UInt8(motionParam2))
        data.append(UInt8(motionParam3))
        
        for _ in 1...7
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func writeBlockSettings(mode:Int, blockNumber:Int, red:Int, green:Int, blue:Int, displayTimeMs:Int, sequenceNum:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 2
        let cmd2:UInt8 = UInt8(mode)
        var data = [UInt8]()
        data.append(UInt8(blockNumber))
        data.append(UInt8(red))
        data.append(UInt8(green))
        data.append(UInt8(blue))
        data.append(UInt8(displayTimeMs))
        data.append(UInt8(sequenceNum))
        
        for _ in 1...10
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func selectModeAndSequence(mode:Int, sequenceNum:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 8
        let cmd2:UInt8 = UInt8(mode)
        var data = [UInt8]()
        data.append(UInt8(sequenceNum))
        
        for _ in 1...15
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func writeFlashingPatternSettings(patternNumber:Int, strobeLength:Int, gapLength:Int, groupGapLength:Int, brightnessSpeed:Int, faderValue:Int, colorRepeat:Int, groupRepeat:Int, groupingNumber:Int, firstColorStrobeLength:Int, firstColorRepeat:Int, firstColorPosition:Int, rampTargetLength:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 7
        let cmd2:UInt8 = UInt8(patternNumber)
        var data = [UInt8]()
        data.append(UInt8(strobeLength))
        data.append(UInt8(gapLength))
        data.append(UInt8(groupGapLength))
        data.append(UInt8(brightnessSpeed))
        data.append(UInt8(faderValue))
        data.append(UInt8(colorRepeat))
        data.append(UInt8(groupRepeat))
        data.append(UInt8(groupingNumber))
        data.append(UInt8(firstColorStrobeLength))
        data.append(UInt8(firstColorRepeat))
        data.append(UInt8(firstColorPosition))
        data.append(UInt8(rampTargetLength))
        
        for _ in 1...4
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func factoryReset(gloveType:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 6
        let cmd2:UInt8 = UInt8(gloveType) //1=Element, 2=Chroma, etc
        var data = [UInt8]()
        
        for _ in 1...16
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func setPWMColor(mode:Int, red:Int, green:Int, blue:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 5
        let cmd2:UInt8 = 0
        var data = [UInt8]()
        data.append(UInt8(red))
        data.append(UInt8(green))
        data.append(UInt8(blue))
        
        for _ in 1...13
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func changeRunMode(mode:Int, availableModes:Int = 0)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 4
        let cmd2:UInt8 = UInt8(mode)
        let numModes:UInt8 = UInt8(availableModes)
        
        var data = [UInt8]()
        data.append(numModes)
        
        for _ in 1...15
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func changeDisplayMode(mode:Int, sequenceNum:Int)->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 3
        let cmd2:UInt8 = UInt8(mode)
        var data = [UInt8]()
        data.append(UInt8(sequenceNum))
        
        for _ in 1...15
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func writeSetHubName(name:String)->BLECommand
    {
        let data:NSData = name.dataUsingEncoding(NSUTF8StringEncoding)!
        return BLECommand(characteristic: EmazingConstants.characteristics.gloveName, data: data)
    }
    
    func writeExitPairingMode()->BLECommand
    {
        let cmdFlag:UInt8 = 85 // Write
        let cmd1:UInt8 = 9
        let cmd2:UInt8 = UInt8(0)

        var data = [UInt8]()
        
        for _ in 1...16
        {
            data.append(UInt8(0x00))
        }
        
        return generateBLECommand(cmdFlag, cmd1: cmd1, cmd2: cmd2, data: data)
    }
    
    func generateBLECommand(cmdFlag:UInt8, cmd1:UInt8, cmd2:UInt8, data:[UInt8])->BLECommand
    {
        var characteristic:String = "Undefined"
        if(cmdFlag == 85) //55
        {
            characteristic = EmazingConstants.characteristics.gloveCommand
        }
        else if(cmdFlag == 165) //A5
        {
            characteristic = EmazingConstants.characteristics.gloveState
        }
        
        let packet = NSMutableData(capacity: 20)
        packet!.appendBytes([cmdFlag] as [UInt8], length: 1)
        packet!.appendBytes([cmd1] as [UInt8], length: 1)
        packet!.appendBytes([cmd2] as [UInt8], length: 1)
        packet!.appendBytes(data, length: 16)
        packet!.appendBytes([0x00] as [UInt8], length: 1)
        
        //Change first byte for CRC
        let crcRange:NSRange = NSMakeRange(19, 1)
        var crc:UInt8 = 0
        for index in 0..<data.count
        {
            crc = data[index] ^ crc
        }
        crc = cmdFlag ^ cmd1 ^ cmd2 ^ crc
        
        packet!.replaceBytesInRange(crcRange, withBytes: [crc])
        
        return BLECommand(characteristic: characteristic, data: packet!)
    }
    
    /*func swap<U:IntegerType>(data:NSData,_ :U.Type) -> NSData{
        let length = data.length / sizeof(U)
        var bytes = [U](count: length, repeatedValue: 0)
        data.getBytes(&bytes, length: data.length)
        // since byteSwapped isn't declare in any protocol, so we have do it by ourselves manually.
        var inverse = bytes.enumerate().reduce([U](count: length, repeatedValue: 0)) { (var pre, ele) -> [U] in
            pre[length - 1 - ele.index] = ele.element
            return pre
        }
        return NSData(bytes: inverse, length: data.length)
    }*/
}

class BLECommand
{
    var characteristic:String = ""
    var dataToSend:NSData!
    
    init(characteristic:String, data:NSData)
    {
        self.characteristic = characteristic
        self.dataToSend = data
    }
}