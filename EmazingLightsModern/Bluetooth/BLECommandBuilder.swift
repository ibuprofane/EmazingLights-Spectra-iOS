import Foundation

struct BLECommand: Equatable, Identifiable {
    var id = UUID()
    var characteristicID: String
    var data: Data

    var hexDescription: String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}

enum BLECommandBuilder {
    static func writeModeSettings(
        mode: Int,
        numColors: Int,
        flashingPatternID: Int,
        blankTime: Int,
        motionType: Int,
        sequenceID: Int,
        motionThreshold: Int,
        motionParam1: Int,
        motionParam2: Int,
        motionParam3: Int
    ) -> BLECommand {
        var data = [
            UInt8(clamping: numColors),
            UInt8(clamping: flashingPatternID),
            UInt8(clamping: blankTime),
            UInt8(clamping: motionType),
            UInt8(clamping: sequenceID),
            UInt8(clamping: motionThreshold),
            UInt8(clamping: motionParam1),
            UInt8(clamping: motionParam2),
            UInt8(clamping: motionParam3)
        ]
        data.append(contentsOf: Array(repeating: 0, count: 7))
        return command(flag: 85, command1: 1, command2: UInt8(clamping: mode), data: data)
    }

    static func writeBlockSettings(
        mode: Int,
        blockNumber: Int,
        red: Int,
        green: Int,
        blue: Int,
        displayTimeMs: Int,
        sequenceNum: Int
    ) -> BLECommand {
        var data = [
            UInt8(clamping: blockNumber),
            UInt8(clamping: red),
            UInt8(clamping: green),
            UInt8(clamping: blue),
            UInt8(clamping: displayTimeMs),
            UInt8(clamping: sequenceNum)
        ]
        data.append(contentsOf: Array(repeating: 0, count: 10))
        return command(flag: 85, command1: 2, command2: UInt8(clamping: mode), data: data)
    }

    static func changeDisplayMode(mode: Int, sequenceNum: Int) -> BLECommand {
        var data = [UInt8(clamping: sequenceNum)]
        data.append(contentsOf: Array(repeating: 0, count: 15))
        return command(flag: 85, command1: 3, command2: UInt8(clamping: mode), data: data)
    }

    static func changeRunMode(mode: Int, availableModes: Int = 0) -> BLECommand {
        var data = [UInt8(clamping: availableModes)]
        data.append(contentsOf: Array(repeating: 0, count: 15))
        return command(flag: 85, command1: 4, command2: UInt8(clamping: mode), data: data)
    }

    static func setPWMColor(red: Int, green: Int, blue: Int) -> BLECommand {
        var data = [UInt8(clamping: red), UInt8(clamping: green), UInt8(clamping: blue)]
        data.append(contentsOf: Array(repeating: 0, count: 13))
        return command(flag: 85, command1: 5, command2: 0, data: data)
    }

    static func factoryReset(gloveType: Int) -> BLECommand {
        command(flag: 85, command1: 6, command2: UInt8(clamping: gloveType), data: Array(repeating: 0, count: 16))
    }

    static func writeFlashingPatternSettings(_ pattern: FlashingPattern, patternNumber: Int? = nil) -> BLECommand {
        var data = [
            UInt8(clamping: pattern.strobeLength),
            UInt8(clamping: pattern.gapLength),
            UInt8(clamping: pattern.groupGapLength),
            UInt8(clamping: pattern.brightnessSpeed),
            UInt8(clamping: pattern.faderSpeed),
            UInt8(clamping: pattern.colorRepeat),
            UInt8(clamping: pattern.groupRepeat),
            UInt8(clamping: pattern.groupingNumber),
            UInt8(clamping: pattern.firstColorStrobeLength),
            UInt8(clamping: pattern.firstColorRepeat),
            UInt8(clamping: pattern.firstColorPosition),
            UInt8(clamping: pattern.rampTargetLength)
        ]
        data.append(contentsOf: Array(repeating: 0, count: 4))
        return command(flag: 85, command1: 7, command2: UInt8(clamping: patternNumber ?? pattern.code), data: data)
    }

    static func selectModeAndSequence(mode: Int, sequenceNum: Int) -> BLECommand {
        var data = [UInt8(clamping: sequenceNum)]
        data.append(contentsOf: Array(repeating: 0, count: 15))
        return command(flag: 85, command1: 8, command2: UInt8(clamping: mode), data: data)
    }

    static func writeExitPairingMode() -> BLECommand {
        command(flag: 85, command1: 9, command2: 0, data: Array(repeating: 0, count: 16))
    }

    static func writeSetHubName(_ name: String) -> BLECommand {
        BLECommand(characteristicID: BLECharacteristicID.gloveName, data: Data(name.utf8))
    }

    private static func command(flag: UInt8, command1: UInt8, command2: UInt8, data: [UInt8]) -> BLECommand {
        let characteristicID = flag == 165 ? BLECharacteristicID.gloveState : BLECharacteristicID.gloveCommand
        let payload = Array(data.prefix(16)) + Array(repeating: 0, count: max(0, 16 - data.count))
        let crc = ([flag, command1, command2] + payload).reduce(UInt8(0), ^)
        var packet = Data([flag, command1, command2])
        packet.append(contentsOf: payload)
        packet.append(crc)
        return BLECommand(characteristicID: characteristicID, data: packet)
    }
}
