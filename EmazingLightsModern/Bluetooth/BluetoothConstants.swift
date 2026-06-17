import Foundation

enum DeviceConstants {
    static let gloveHardwareName = "bluenrgGlove"
    static let photoHubHardwareName = "bluenrg"
    static let photoHubFallbackName = "PhotoHub"
    static let photoHubDefaultDisplayName = "PhotoHub"
}

enum BLECharacteristicID {
    static let generalStatusCode = "C69F846D-1AE9-F688-E740-3FE13E88ED69"
    static let batteryLevel = "E3DAF87B-ABE9-4A8F-9A42-1F27D2FAA8FD"
    static let profileVersion = "D5F90FAD-00EA-5AAB-FE47-3D49517EA52C"
    static let gloveName = "CBA9B4F5-BFED-959D-5741-BF7340D19491"
    static let gloveProgram = "9020CB85-1F69-FBA8-5F45-5915ED83A0D6"
    static let gloveCommand = "58511D0A-2CD1-6188-5445-9F98C91BE785"
    static let gloveResponse = "217E8843-D35D-A180-F041-7298D2B02B5A"
    static let gloveState = "58F54A2A-0E08-0CBD-1340-E3DBB208B41B"
    static let numberOfModeSlots = "FAF8D6E0-9B1C-22A9-514F-F64D77DF47C9"
    static let selectModeSlot = "385BE28E-8237-9EB4-EF45-6E8C338274BE"
    static let slotFlashingPattern = "44FC3A9D-E11A-4E81-C045-102BFB74B8DC"
    static let slotColors = "400294D2-8384-03BE-9442-66B518F5287A"
    static let slotMotion = "7C5F1C7C-A330-AEAB-E241-D518DBD6FD6B"
    static let sensitivity = "889BF607-5EE7-51A6-544F-8EC64F351745"
    static let numberOfCustomColorSlots = "2D3ABB5C-72E7-93A0-A940-838A2BC9D761"
    static let selectColorSlot = "F92D0742-1D22-F6B6-6A41-B082573417F3"
    static let customColor = "47DF3754-2B44-1790-4C4F-6137CEEEDE0D"
    static let slotStatus = "EF4BB646-D7B8-D88B-764E-236B60BCAF0E"
}

enum BLEServiceID {
    static let advertisedServiceUUID = "F4DB6DA0-2FCF-D296-A741-42FF6328EF42"
    static let hubInformationService = "B1BC9DF2-8746-50AC-1046-FC60DD6121C7"
    static let hubControlService = "1D797C00-5BBB-E1BF-3544-07F9C160632E"
    static let gloveInformationService = "A7FDEE49-588F-AF95-9D42-E15934C00D41"
}
