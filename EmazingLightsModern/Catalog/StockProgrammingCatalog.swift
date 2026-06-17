import Foundation

enum StockProgrammingCatalog {
    static func make() -> ProgrammingCatalog {
        let colors = makeColors()
        let color = Dictionary(uniqueKeysWithValues: colors.map { ($0.name, $0) })
        let patterns = makePatterns()
        let pattern = Dictionary(uniqueKeysWithValues: patterns.map { ($0.name, $0) })
        let testPalette = Palette(
            name: "Test Palette",
            colors: [
                color["Red"]!, color["Green"]!, color["Blue"]!, color["Yellow"]!, color["Hot Pink"]!,
                color["Lens Flare"]!, color["Sky Blue"]!, color["Cyan"]!, color["Turquoise"]!, color["Orange"]!
            ]
        )
        let basicPalette = Palette(name: "Basic", colors: [color["White"]!, color["Blank"]!, color["Red"]!, color["Green"]!, color["Blue"]!])

        let elementModes = [
            mode("FESTIVAL", sequence(pattern["Hyperstrobe"]!, ["Silver", "Tombstone", "White"], color), sequence(pattern["Strobie"]!, ["Cyan", "Lavender", "Tombstone", "Orange", "Lime", "Lime Green"], color)),
            mode("ALL AROUND", sequence(pattern["Strobe"]!, ["Cosmic Owl", "Lens Flare", "Cyan"], color), sequence(pattern["Strobe"]!, ["Cosmic Owl", "Lens Flare", "Cyan"], color)),
            mode("TUTTING", sequence(pattern["Chroma"]!, ["Lime", "Light Pink", "Light Blue", "Blank", "Blank", "Blank", "Blank"], color), sequence(pattern["Ultra Dops"]!, ["Light Pink", "Lime", "Light Blue", "Blank", "Blank", "Blank", "Blank"], color)),
            mode("TECH", sequence(pattern["BlinkE"]!, ["Light Blue", "Tombstone", "Snarf", "Cosmic Owl"], color), sequence(pattern["Strobe"]!, ["Light Blue", "Tombstone", "Snarf", "Cosmic Owl"], color)),
            mode("MUSICALITY", sequence(pattern["Strobie"]!, ["Lens Flare", "Tombstone", "Blank"], color), sequence(pattern["Strobe"]!, ["Lime", "White"], color)),
            mode("FLOW", sequence(pattern["Strobie"]!, ["Mint", "Mint", "Cyan", "Cyan", "Tombstone", "Tombstone"], color), sequence(pattern["Dops"]!, ["Mint", "Mint", "Cyan", "Cyan", "Tombstone", "Tombstone"], color))
        ]

        let ctrlModes = [
            repeatedMode("TOXIC FUSION", pattern["Krush"]!, ["Ban Yellow", "Mint", "Luna", "Pink", "Peach", "Space Ghost"], color),
            repeatedMode("OVERCLOCKED", pattern["Strobe"]!, ["Purple", "Purple", "Luna", "Red"], color),
            repeatedMode("FRAG MODE", pattern["Strobie"]!, ["Silver", "Lime Green", "Red", "Mint"], color),
            repeatedMode("CRYO DREAMS", pattern["Dops"]!, ["Blue", "Sky Blue", "Turquoise", "Light Blue", "Mint", "Seafoam", "Luna"], color),
            repeatedMode("CHROMATECH", pattern["Chroma"]!, ["Warm White", "Lavender", "Blank", "Blank", "Luna", "Blank", "Blank"], color),
            repeatedMode("COOL CTRL MODE", pattern["Strobe"]!, ["Mint", "Mint", "Cyan", "Cyan", "Tombstone", "Tombstone"], color)
        ]

        let chroma24Modes = [
            repeatedMode("RAV'N REMAKE", pattern["Strobe"]!, ["Red", "Lime Green", "Turquoise", "Lime Green", "Turquoise"], color),
            repeatedMode("iMORPH UNITY REMAKE", pattern["Hyperstrobe"]!, ["Pink", "Lavender", "Light Blue", "Seafoam", "Mint", "Lime Green", "Blush"], color),
            repeatedMode("STARRY NIGHT", pattern["Dops"]!, ["Purple", "Luna", "Seafoam", "Peach", "Red", "White"], color),
            repeatedMode("COLOR WHEEL", pattern["Strobie"]!, ["Red", "Orange", "Ban Yellow", "Lime Green", "Seafoam", "Sky Blue", "Purple"], color),
            repeatedMode("FACEMELT CHROMA", pattern["Chroma"]!, ["Ban Yellow", "Blue", "Blue", "Silver", "Orange", "Orange"], color),
            repeatedMode("COOL 24 MODE", pattern["Strobe"]!, ["Mint", "Mint", "Cyan", "Cyan", "Tombstone", "Tombstone"], color)
        ]

        let ezliteModes = [
            repeatedMode("HYPER STROBE", pattern["Hyperstrobe"]!, ["Purple", "Orange", "Green"], color),
            repeatedMode("STROBE", pattern["Strobe"]!, ["Pink", "Yellow", "Blue"], color),
            repeatedMode("STROBIE", pattern["Strobie"]!, ["Mint", "Silver", "Blue"], color),
            repeatedMode("COOL EZLITE MODE 1", pattern["Strobie"]!, ["Red", "Orange", "Ban Yellow", "Lime Green", "Seafoam", "Sky Blue", "Purple"], color),
            repeatedMode("COOL EZLITE MODE 2", pattern["Chroma"]!, ["Ban Yellow", "Blue", "Blue", "Silver", "Orange", "Orange"], color),
            repeatedMode("COOL EZLITE MODE 3", pattern["Strobe"]!, ["Mint", "Mint", "Cyan", "Cyan", "Tombstone", "Tombstone"], color)
        ]

        let enovaModes = [
            repeatedMode("CHROMA", pattern["Chroma"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("DOPS", pattern["Dops"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("iNOVA BLINK", pattern["Inova Blink"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("COOL ENOVA MODE 1", pattern["Strobie"]!, ["Red", "Orange", "Ban Yellow", "Lime Green", "Seafoam", "Sky Blue", "Purple"], color),
            repeatedMode("COOL ENOVA MODE 2", pattern["Chroma"]!, ["Ban Yellow", "Blue", "Blue", "Silver", "Orange", "Orange"], color),
            repeatedMode("COOL ENOVA MODE 3", pattern["Strobe"]!, ["Mint", "Mint", "Cyan", "Cyan", "Tombstone", "Tombstone"], color)
        ]

        let flowModes = [
            repeatedMode("CHROMA", pattern["Chroma"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("PULSE", pattern["Pulse"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("DASH MORPH", pattern["Dash Morph"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("STROBE FADE", pattern["Strobe Fade"]!, ["Red", "Orange", "Blue"], color),
            repeatedMode("STROBE MORPH", pattern["Strobe Morph"]!, ["Red", "Green", "Blue"], color),
            repeatedMode("SHAPESHIFTER", pattern["Shape Shifter"]!, ["Red", "Green", "Blue"], color)
        ]

        let elementFinger = FingerProgram(modes: elementModes, defaultPalette: testPalette)
        var ctrlFinger = FingerProgram(modes: ctrlModes, defaultPalette: testPalette)
        var chroma24Finger = FingerProgram(modes: chroma24Modes, defaultPalette: testPalette)
        var ezliteFinger = FingerProgram(modes: ezliteModes, defaultPalette: testPalette)
        var enovaFinger = FingerProgram(modes: enovaModes, defaultPalette: testPalette)
        let flowFinger = FingerProgram(modes: flowModes, defaultPalette: testPalette)

        ctrlFinger.disabledModes[5] = true
        chroma24Finger.disabledModes[5] = true
        ezliteFinger.disabledModes[3] = true
        ezliteFinger.disabledModes[4] = true
        ezliteFinger.disabledModes[5] = true
        enovaFinger.disabledModes[3] = true
        enovaFinger.disabledModes[4] = true
        enovaFinger.disabledModes[5] = true

        let chips = [
            ChipProgram(name: "Element", imageName: "element", finger: elementFinger, tags: ["Motion", "Favorites"]),
            ChipProgram(name: "Chroma 24", imageName: "chroma", finger: chroma24Finger, tags: ["Favorites"]),
            ChipProgram(name: "ChromaCTRL", imageName: "chromactrl", finger: ctrlFinger, tags: ["Favorites"]),
            ChipProgram(name: "Flow", imageName: "flow", finger: flowFinger, tags: ["Favorites"]),
            ChipProgram(name: "EZLite 2.0", imageName: "ezlite", finger: ezliteFinger, tags: ["Classic"]),
            ChipProgram(name: "eNOVA", imageName: "enova", finger: enovaFinger, tags: ["Classic"])
        ]

        let leftHand = HandProgram(handID: 0, emotion: 0, fingers: Array(repeating: elementFinger, count: 5))
        let rightHand = HandProgram(handID: 1, emotion: 0, fingers: Array(repeating: elementFinger, count: 5))
        let gloveSets = chips.map { chip in
            GloveSetProgram(name: chip.name, imageName: chip.imageName, glovePair: [leftHand, rightHand], tags: chip.tags)
        }

        return ProgrammingCatalog(
            stockGloveSets: gloveSets,
            stockChips: chips,
            stockFlashingPatterns: patterns,
            stockModes: elementModes + ctrlModes + chroma24Modes + ezliteModes + enovaModes + flowModes,
            stockPalettes: [basicPalette],
            stockColors: colors,
            customPalettes: [testPalette]
        )
    }

    private static func makeColors() -> [LEDColor] {
        [
            LEDColor(name: "White", red: 224, green: 255, blue: 160, fixedColorRef: 0),
            LEDColor(name: "Blank", red: 0, green: 0, blue: 0, fixedColorRef: 1),
            LEDColor(name: "Red", red: 255, green: 0, blue: 0, fixedColorRef: 2),
            LEDColor(name: "Orange", red: 255, green: 64, blue: 0, fixedColorRef: 3),
            LEDColor(name: "Ban Yellow", red: 255, green: 160, blue: 0, fixedColorRef: 4),
            LEDColor(name: "Yellow", red: 255, green: 192, blue: 0, fixedColorRef: 5),
            LEDColor(name: "Cosmic Owl", red: 255, green: 240, blue: 32, fixedColorRef: 6),
            LEDColor(name: "Lime", red: 255, green: 255, blue: 0, fixedColorRef: 7),
            LEDColor(name: "Lime Green", red: 128, green: 255, blue: 0, fixedColorRef: 8),
            LEDColor(name: "Green", red: 0, green: 255, blue: 0, fixedColorRef: 9),
            LEDColor(name: "Mint", red: 128, green: 255, blue: 96, fixedColorRef: 10),
            LEDColor(name: "Seafoam", red: 0, green: 208, blue: 32, fixedColorRef: 11),
            LEDColor(name: "Turquoise", red: 0, green: 208, blue: 96, fixedColorRef: 12),
            LEDColor(name: "Cyan", red: 0, green: 192, blue: 128, fixedColorRef: 13),
            LEDColor(name: "Light Blue", red: 0, green: 224, blue: 255, fixedColorRef: 14),
            LEDColor(name: "Sky Blue", red: 0, green: 96, blue: 255, fixedColorRef: 15),
            LEDColor(name: "Blue", red: 0, green: 0, blue: 255, fixedColorRef: 16),
            LEDColor(name: "Lens Flare", red: 64, green: 64, blue: 255, fixedColorRef: 17),
            LEDColor(name: "Purple", red: 48, green: 0, blue: 255, fixedColorRef: 18),
            LEDColor(name: "Lavender", red: 192, green: 96, blue: 255, fixedColorRef: 19),
            LEDColor(name: "Blush", red: 255, green: 64, blue: 160, fixedColorRef: 20),
            LEDColor(name: "Pink", red: 224, green: 0, blue: 96, fixedColorRef: 21),
            LEDColor(name: "Hot Pink", red: 224, green: 0, blue: 32, fixedColorRef: 22),
            LEDColor(name: "Light Pink", red: 255, green: 64, blue: 64, fixedColorRef: 23),
            LEDColor(name: "Peach", red: 255, green: 128, blue: 32, fixedColorRef: 24),
            LEDColor(name: "Snarf", red: 255, green: 160, blue: 96, fixedColorRef: 25),
            LEDColor(name: "Warm White", red: 255, green: 160, blue: 32, fixedColorRef: 26),
            LEDColor(name: "Silver", red: 160, green: 224, blue: 255, fixedColorRef: 27),
            LEDColor(name: "Luna", red: 128, green: 224, blue: 255, fixedColorRef: 28),
            LEDColor(name: "Tombstone", red: 64, green: 128, blue: 96, fixedColorRef: 29),
            LEDColor(name: "Space Ghost", red: 144, green: 224, blue: 32, fixedColorRef: 30)
        ]
    }

    private static func makePatterns() -> [FlashingPattern] {
        [
            FlashingPattern(name: "Strobe", imageName: "1-Strobe", code: 1, strobeLength: 5, gapLength: 8),
            FlashingPattern(name: "Hyperstrobe", imageName: "2-Hyperstrobe", code: 2, strobeLength: 16, gapLength: 17),
            FlashingPattern(name: "Dops", imageName: "3-Dops", code: 3, strobeLength: 1, gapLength: 9),
            FlashingPattern(name: "Shadow", imageName: "4-Shadow", code: 4, strobeLength: 1, gapLength: 2),
            FlashingPattern(name: "Strobie", imageName: "5-Strobie", code: 5, strobeLength: 3, gapLength: 23),
            FlashingPattern(name: "Flicker", imageName: "6-Flicker", code: 6, strobeLength: 1, gapLength: 50),
            FlashingPattern(name: "Chroma", imageName: "7-Chroma", code: 7, strobeLength: 9, gapLength: 0),
            FlashingPattern(name: "Tracer", imageName: "8-Tracer", code: 8),
            FlashingPattern(name: "Centerpoint", imageName: "9-Centerpoint", code: 9),
            FlashingPattern(name: "BlinkE", imageName: "10-BlinkE", code: 10),
            FlashingPattern(name: "Ultra Dops", imageName: "11-UltraDops", code: 11),
            FlashingPattern(name: "Inova Blink", imageName: "12-InovaBlink", code: 12),
            FlashingPattern(name: "Strobe Fade", imageName: "13-StrobeFade", code: 13),
            FlashingPattern(name: "Strobe Morph", imageName: "14-StrobeMorph", code: 14),
            FlashingPattern(name: "Dash Morph", imageName: "15-DashMorph", code: 15),
            FlashingPattern(name: "HeartBeat", imageName: "16-HeartBeat", code: 16),
            FlashingPattern(name: "Pulse", imageName: "17-Pulse", code: 17),
            FlashingPattern(name: "Shape Shifter", imageName: "18-ShapeShifter", code: 18),
            FlashingPattern(name: "Vex", imageName: "19-Vex", code: 19),
            FlashingPattern(name: "Krush", imageName: "20-Krush", code: 20),
            FlashingPattern(name: "OG Ribbon", imageName: "", code: 21),
            FlashingPattern(name: "Kandi Mode", imageName: "", code: 22),
            FlashingPattern(name: "Candy Strobe", imageName: "", code: 23),
            FlashingPattern(name: "X Change", imageName: "", code: 24),
            FlashingPattern(name: "Matrix Tribbon", imageName: "", code: 25),
            FlashingPattern(name: "X Morph", imageName: "", code: 26),
            FlashingPattern(name: "Dash Dot", imageName: "", code: 27),
            FlashingPattern(name: "Puppet's Pattern", imageName: "", code: 28),
            FlashingPattern(name: "Edge", imageName: "", code: 29),
            FlashingPattern(name: "Dash Dops", imageName: "", code: 30),
            FlashingPattern(name: "Seizure Strobe", imageName: "", code: 31),
            FlashingPattern(name: "Stutter Strobe", imageName: "", code: 32),
            FlashingPattern(name: "Inova Dops", imageName: "", code: 33),
            FlashingPattern(name: "Mini-Edge", imageName: "", code: 34),
            FlashingPattern(name: "VexFlow", imageName: "", code: 35),
            FlashingPattern(name: "Chroma Morph", imageName: "", code: 36),
            FlashingPattern(name: "Chroma Fade", imageName: "", code: 37),
            FlashingPattern(name: "Extended Strobe Fade", imageName: "", code: 38),
            FlashingPattern(name: "Hyper Blink", imageName: "", code: 39),
            FlashingPattern(name: "Heartbeat 1", imageName: "", code: 40),
            FlashingPattern(name: "Heartbeat 2", imageName: "", code: 41),
            FlashingPattern(name: "Heartbeat 3", imageName: "", code: 42),
            FlashingPattern(name: "Onebeat", imageName: "", code: 43),
            FlashingPattern(name: "Fastbeat", imageName: "", code: 44),
            FlashingPattern(name: "IMax Genesis Tribbon", imageName: "", code: 45),
            FlashingPattern(name: "IMax Tracer Strobie", imageName: "", code: 46),
            FlashingPattern(name: "Blending Bliss", imageName: "", code: 47)
        ]
    }

    private static func mode(_ name: String, _ first: LEDSequence, _ second: LEDSequence) -> LEDMode {
        LEDMode(name: name, sequences: [first, second])
    }

    private static func repeatedMode(
        _ name: String,
        _ pattern: FlashingPattern,
        _ colorNames: [String],
        _ colors: [String: LEDColor]
    ) -> LEDMode {
        let seq = sequence(pattern, colorNames, colors)
        return LEDMode(name: name, sequences: [seq, seq])
    }

    private static func sequence(_ pattern: FlashingPattern, _ colorNames: [String], _ colors: [String: LEDColor]) -> LEDSequence {
        LEDSequence(flashingPattern: pattern, colorSet: colorNames.compactMap { colors[$0] })
    }
}
