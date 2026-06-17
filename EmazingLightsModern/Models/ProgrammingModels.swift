import Foundation
import SwiftUI

struct LEDColor: Codable, Equatable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var red: Int
    var green: Int
    var blue: Int
    var fixedColorRef: Int?
    var disabled: Bool

    init(
        name: String,
        red: Int,
        green: Int,
        blue: Int,
        fixedColorRef: Int? = nil,
        disabled: Bool = false,
        id: UUID = UUID()
    ) {
        self.id = id
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
        self.fixedColorRef = fixedColorRef
        self.disabled = disabled
    }

    var swiftUIColor: Color {
        Color(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0
        )
    }

    func tinted(_ tint: ColorTint) -> LEDColor {
        guard tint != .high else { return self }
        let factor = tint == .medium ? 0.20 : 0.05
        return LEDColor(
            name: "\(name) \(tint.rawValue)",
            red: Int(Double(red) * factor),
            green: Int(Double(green) * factor),
            blue: Int(Double(blue) * factor),
            fixedColorRef: fixedColorRef,
            disabled: disabled,
            id: id
        )
    }

    static let disabledColor = LEDColor(name: "Disabled", red: 0, green: 0, blue: 0, disabled: true)
}

enum ColorTint: String, Codable, CaseIterable, Identifiable {
    case high = "H"
    case medium = "M"
    case low = "L"

    var id: String { rawValue }
    var label: String {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        }
    }
}

struct FlashingPattern: Codable, Equatable, Identifiable {
    var id: Int { code }
    var name: String
    var imageName: String
    var code: Int
    var strobeLength: Int = 15
    var gapLength: Int = 15
    var groupGapLength: Int = 0
    var faderOption: Int = 0
    var faderSpeed: Int = 0
    var brightnessSpeed: Int = 0
    var colorRepeat: Int = 0
    var groupRepeat: Int = 0
    var groupingNumber: Int = 0
    var firstColorStrobeLength: Int = 0
    var firstColorRepeat: Int = 0
    var firstColorPosition: Int = 0
    var rampOption: Int = 0
    var rampTargetLength: Int = 0
}

struct LEDSequence: Codable, Equatable, Identifiable {
    var id = UUID()
    var flashingPattern: FlashingPattern
    var colorSet: [LEDColor]
    var colorTints: [ColorTint]
    var maxColors: Int = 7
    var threshold: Int = 0
    var customFlashingPattern: Bool = false

    init(
        flashingPattern: FlashingPattern,
        colorSet: [LEDColor],
        colorTints: [ColorTint]? = nil,
        maxColors: Int = 7,
        threshold: Int = 0,
        customFlashingPattern: Bool = false
    ) {
        self.flashingPattern = flashingPattern
        self.colorSet = colorSet
        self.colorTints = colorTints ?? Array(repeating: .high, count: maxColors)
        self.maxColors = maxColors
        self.threshold = threshold
        self.customFlashingPattern = customFlashingPattern
    }
}

struct LEDMode: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var sequences: [LEDSequence]
    var emotionEffect: Int = 0
    var emotionSpeedOption: Int = 0
    var emotionParam1: Int = 0
    var emotionParam2: Int = 0
    var emotionParam3: Int = 0
}

struct Palette: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var colors: [LEDColor]
}

struct FingerProgram: Codable, Equatable, Identifiable {
    var id = UUID()
    var disabledModes: [Bool]
    var modes: [LEDMode]
    var overrideModes: [Int: LEDMode] = [:]
    var defaultPalette: Palette

    init(modes: [LEDMode], defaultPalette: Palette, overrideModes: [Int: LEDMode] = [:]) {
        self.disabledModes = Array(repeating: false, count: modes.count)
        self.modes = modes
        self.overrideModes = overrideModes
        self.defaultPalette = defaultPalette
    }

    func activeMode(at index: Int) -> LEDMode {
        overrideModes[index] ?? modes[index]
    }
}

struct ChipProgram: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
    var userDescription: String = ""
    var finger: FingerProgram
    var tags: Set<String>
}

struct HandProgram: Codable, Equatable, Identifiable {
    var id = UUID()
    var handID: Int
    var emotion: Int
    var fingers: [FingerProgram]
}

struct GloveSetProgram: Codable, Equatable, Identifiable {
    var id = UUID()
    var name: String
    var imageName: String
    var userDescription: String = ""
    var glovePair: [HandProgram]
    var tags: Set<String>
}

struct ProgrammingCatalog: Codable {
    var stockGloveSets: [GloveSetProgram]
    var stockChips: [ChipProgram]
    var stockFlashingPatterns: [FlashingPattern]
    var stockModes: [LEDMode]
    var stockPalettes: [Palette]
    var stockColors: [LEDColor]
    var customChips: [ChipProgram] = []
    var customFlashingPatterns: [FlashingPattern] = []
    var customPalettes: [Palette] = []
}

struct KnownHub: Codable, Equatable, Identifiable {
    var id: String { uuid }
    var uuid: String
    var name: String
}

struct DiscoveredHub: Identifiable, Equatable {
    var id: UUID
    var uuidString: String
    var name: String
    var isPairingMode: Bool
    var rssi: Int
}
