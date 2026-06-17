//
//  Constants.swift
//  EmazingLights
//
//  Created by Kevin Kolasinski on 12/2/15.
//  Copyright © 2015 Emazing Group. All rights reserved.
//

import Foundation

struct EmazingConstants {
    static var constants:Constants = Constants()
    static var characteristics:Characteristics = Characteristics()
    static var services:Services = Services()
}

class Constants:NSObject
{
    let colorNames = DBColorNames()
    let customColorLimit = 200
    //TODO: Update these with the actual product names (as broadcast by BLE)
    let gloveHardwareName = "bluenrgGlove"
    let photoHubHardwareName = "bluenrg"
    let photoHubDefaultDisplayName = "PhotoHub"
}

class Characteristics:NSObject
{
    //Glove Information Service
    let generalStatusCode:String = "C69F846D-1AE9-F688-E740-3FE13E88ED69"
    let batteryLevel:String = "E3DAF87B-ABE9-4A8F-9A42-1F27D2FAA8FD"
    let firmwareVersion:String = "B66DAC3C-DA9D-DABE-524B-32C864BBBA0E"
    let profileVersion:String = "D5F90FAD-00EA-5AAB-FE47-3D49517EA52C"
    let gloveName:String = "CBA9B4F5-BFED-959D-5741-BF7340D19491"
    let gloveProgram:String = "9020CB85-1F69-FBA8-5F45-5915ED83A0D6"
    
    //Glove Command Service
    let gloveCommand:String = "58511D0A-2CD1-6188-5445-9F98C91BE785"
    let gloveResponse:String = "217E8843-D35D-A180-F041-7298D2B02B5A"
    let gloveState:String = "58F54A2A-0E08-0CBD-1340-E3DBB208B41B"
    
    //Glove Information Service
    let numberOfModeSlots:String = "FAF8D6E0-9B1C-22A9-514F-F64D77DF47C9"
    let selectModeSlot:String = "385BE28E-8237-9EB4-EF45-6E8C338274BE"
    let slotFlashingPattern:String = "44FC3A9D-E11A-4E81-C045-102BFB74B8DC"
    let slotColors:String = "400294D2-8384-03BE-9442-66B518F5287A"
    let slotMotion:String = "7C5F1C7C-A330-AEAB-E241-D518DBD6FD6B"
    let sensitivity:String = "889BF607-5EE7-51A6-544F-8EC64F351745"
    let numberOfCustomColorSlots:String = "2D3ABB5C-72E7-93A0-A940-838A2BC9D761"
    let selectColorSlot:String = "F92D0742-1D22-F6B6-6A41-B082573417F3"
    let customColor:String = "47DF3754-2B44-1790-4C4F-6137CEEEDE0D"
    let slotStatus:String = "EF4BB646-D7B8-D88B-764E-236B60BCAF0E"
    
    //OTA Firmware Upgrade Service
    let otaNewImage:String = "210F99F0-8508-11E3-BAA7-0800200C9A66"
    let otaNewImageContent:String = "2691AA80-8508-11E3-BAA7-0800200C9A66"
    let otaExpectedSequenceNumber:String = "2BDC5760-8508-11E3-BAA7-0800200C9A66"
    //let serviceVersion:String = "fae80af1-8441-4961-885b-7a41814c4f86"
    
    
}

class Services:NSObject
{
    let advertisedServiceUUID:String = "F4DB6DA0-2FCF-D296-A741-42FF6328EF42"
    //let advertisedServiceUUID:String = "ADABFB00-6E7D-4601-BDA2-BFFAA68956BA" //FitBit - do not use
    
    let hubInformationService:String = "B1BC9DF2-8746-50AC-1046-FC60DD6121C7"
    let hubControlService:String = "1D797C00-5BBB-E1BF-3544-07F9C160632E"
    let gloveInformationService:String = "A7FDEE49-588F-AF95-9D42-E15934C00D41"
    let otaFirmwareUpgradeService:String = "8A97F7C0-8506-11E3-BAA7-0800200C9A66"
}

enum PageMode
{
    case Edit
    case Select
    case DirectEdit
}