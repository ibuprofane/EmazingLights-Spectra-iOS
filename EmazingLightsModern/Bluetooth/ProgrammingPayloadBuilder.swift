import Foundation

struct ProgrammingPayloadBuilder {
    let previewModeSlot = 0
    let previewModeSequenceSlot = 1
    let runModeDisplay = 1
    let runModePhoto = 2
    let runModeColor = 3
    let customFlashingPatternStartIndex = 48

    func fullChipSync(for chip: ChipProgram) -> [BLECommand] {
        var customPatternIndex = customFlashingPatternStartIndex
        var payload: [BLECommand] = []
        var activeModeIndex = 0

        for index in chip.finger.modes.indices where chip.finger.disabledModes[index] == false {
            activeModeIndex += 1
            let mode = chip.finger.activeMode(at: index)
            payload += modeAndBlocks(for: mode, modeIndex: activeModeIndex, customPatternIndex: &customPatternIndex)
        }

        payload.append(BLECommandBuilder.changeRunMode(mode: runModeDisplay, availableModes: activeModeIndex))
        return payload
    }

    func previewSequence(_ sequence: LEDSequence) -> [BLECommand] {
        var payload: [BLECommand] = []
        var patternCode = sequence.flashingPattern.code

        if sequence.customFlashingPattern {
            patternCode = customFlashingPatternStartIndex
        }

        payload.append(
            BLECommandBuilder.writeModeSettings(
                mode: previewModeSlot,
                numColors: sequence.colorSet.count,
                flashingPatternID: patternCode,
                blankTime: 0,
                motionType: 0,
                sequenceID: previewModeSequenceSlot,
                motionThreshold: 0,
                motionParam1: 0,
                motionParam2: 0,
                motionParam3: 0
            )
        )

        for blockIndex in sequence.colorSet.indices {
            let components = componentColors(sequence: sequence, colorSlot: blockIndex)
            payload.append(
                BLECommandBuilder.writeBlockSettings(
                    mode: previewModeSlot,
                    blockNumber: blockIndex + 1,
                    red: components.red,
                    green: components.green,
                    blue: components.blue,
                    displayTimeMs: 0,
                    sequenceNum: previewModeSequenceSlot
                )
            )
        }

        if sequence.customFlashingPattern {
            payload.append(BLECommandBuilder.writeFlashingPatternSettings(sequence.flashingPattern, patternNumber: patternCode))
        }

        payload.append(BLECommandBuilder.changeDisplayMode(mode: previewModeSlot, sequenceNum: previewModeSequenceSlot))
        payload.append(BLECommandBuilder.changeRunMode(mode: runModeDisplay))
        return payload
    }

    func previewPattern(id: Int) -> [BLECommand] {
        [
            BLECommandBuilder.writeModeSettings(
                mode: previewModeSlot,
                numColors: 3,
                flashingPatternID: id,
                blankTime: 0,
                motionType: 0,
                sequenceID: previewModeSequenceSlot,
                motionThreshold: 0,
                motionParam1: 0,
                motionParam2: 0,
                motionParam3: 0
            ),
            BLECommandBuilder.writeBlockSettings(mode: previewModeSlot, blockNumber: 1, red: 255, green: 0, blue: 0, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot),
            BLECommandBuilder.writeBlockSettings(mode: previewModeSlot, blockNumber: 2, red: 0, green: 255, blue: 0, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot),
            BLECommandBuilder.writeBlockSettings(mode: previewModeSlot, blockNumber: 3, red: 0, green: 0, blue: 255, displayTimeMs: 0, sequenceNum: previewModeSequenceSlot),
            BLECommandBuilder.changeDisplayMode(mode: previewModeSlot, sequenceNum: previewModeSequenceSlot),
            BLECommandBuilder.changeRunMode(mode: runModeDisplay)
        ]
    }

    func enableCustomColorPreviewMode() -> [BLECommand] {
        [BLECommandBuilder.changeRunMode(mode: runModeColor)]
    }

    func previewCustomColor(_ color: LEDColor) -> [BLECommand] {
        [BLECommandBuilder.setPWMColor(red: color.red, green: color.green, blue: color.blue)]
    }

    func renameHubAndExitPairing(name: String) -> [BLECommand] {
        [BLECommandBuilder.writeSetHubName(name), BLECommandBuilder.writeExitPairingMode()]
    }

    private func modeAndBlocks(for mode: LEDMode, modeIndex: Int, customPatternIndex: inout Int) -> [BLECommand] {
        var payload: [BLECommand] = []

        for sequenceNumber in 0...1 {
            guard mode.sequences.indices.contains(sequenceNumber) else { continue }
            let sequence = mode.sequences[sequenceNumber]
            let pattern = sequence.flashingPattern
            var patternCode = pattern.code

            if sequence.customFlashingPattern && customPatternIndex <= customFlashingPatternStartIndex + 3 {
                patternCode = customPatternIndex
                payload.append(BLECommandBuilder.writeFlashingPatternSettings(pattern, patternNumber: patternCode))
                customPatternIndex += 1
            }

            payload.append(
                BLECommandBuilder.writeModeSettings(
                    mode: modeIndex,
                    numColors: sequence.colorSet.count,
                    flashingPatternID: patternCode,
                    blankTime: 0,
                    motionType: mode.emotionEffect,
                    sequenceID: sequenceNumber + 1,
                    motionThreshold: mode.emotionSpeedOption,
                    motionParam1: mode.emotionParam1,
                    motionParam2: mode.emotionParam2,
                    motionParam3: mode.emotionParam3
                )
            )

            for blockIndex in sequence.colorSet.indices {
                let components = componentColors(sequence: sequence, colorSlot: blockIndex)
                payload.append(
                    BLECommandBuilder.writeBlockSettings(
                        mode: modeIndex,
                        blockNumber: blockIndex + 1,
                        red: components.red,
                        green: components.green,
                        blue: components.blue,
                        displayTimeMs: 0,
                        sequenceNum: sequenceNumber + 1
                    )
                )
            }
        }

        return payload
    }

    private func componentColors(sequence: LEDSequence, colorSlot: Int) -> (red: Int, green: Int, blue: Int) {
        let tint = sequence.colorTints.indices.contains(colorSlot) ? sequence.colorTints[colorSlot] : .high
        let color = sequence.colorSet[colorSlot].tinted(tint)
        return (color.red, color.green, color.blue)
    }
}
