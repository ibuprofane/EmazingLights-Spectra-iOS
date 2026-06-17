import SwiftUI

struct ProgramLibraryView: View {
    @EnvironmentObject private var store: ProgrammingStore

    var body: some View {
        NavigationStack {
            List {
                Section("Stock Programs") {
                    ForEach(store.catalog.stockChips.indices, id: \.self) { index in
                        chipLink(chip: $store.catalog.stockChips[index])
                    }
                }
                if !store.catalog.customChips.isEmpty {
                    Section("Custom Programs") {
                        ForEach(store.catalog.customChips.indices, id: \.self) { index in
                            chipLink(chip: $store.catalog.customChips[index])
                        }
                    }
                }
            }
            .navigationTitle("Programs")
        }
    }

    private func chipLink(chip: Binding<ChipProgram>) -> some View {
        NavigationLink {
            ChipDetailView(chip: chip)
        } label: {
            HStack(spacing: 12) {
                ResourceImage(name: chip.wrappedValue.imageName)
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                VStack(alignment: .leading, spacing: 4) {
                    Text(chip.wrappedValue.name)
                        .font(.headline)
                    Text(chip.wrappedValue.tags.sorted().joined(separator: " / "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 3)
        }
    }
}

struct ChipDetailView: View {
    @EnvironmentObject private var store: ProgrammingStore
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService
    @Binding var chip: ChipProgram

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ResourceImage(name: chip.imageName)
                        .frame(width: 88, height: 88)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    VStack(alignment: .leading) {
                        Text(chip.name)
                            .font(.title2.bold())
                        Text("\(chip.finger.modes.count) modes")
                            .foregroundStyle(.secondary)
                    }
                }
                Button {
                    bluetooth.sync(chip)
                } label: {
                    Label("Sync Chip", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(.borderedProminent)
            }

            ForEach(chip.finger.modes.indices, id: \.self) { modeIndex in
                let mode = chip.finger.modes[modeIndex]
                Section {
                    Toggle("Enabled", isOn: enabledBinding(for: modeIndex))
                    ForEach(mode.sequences.indices, id: \.self) { sequenceIndex in
                        NavigationLink {
                            SequenceEditorView(
                                sequence: sequenceBinding(mode: modeIndex, sequence: sequenceIndex),
                                stockPatterns: store.catalog.stockFlashingPatterns,
                                customPatterns: store.catalog.customFlashingPatterns,
                                stockColors: store.catalog.stockColors,
                                paletteColors: chip.finger.defaultPalette.colors
                            )
                        } label: {
                            SequenceRow(sequence: mode.sequences[sequenceIndex])
                        }
                    }
                } header: {
                    Text("\(modeIndex + 1). \(mode.name)")
                }
            }
        }
        .navigationTitle(chip.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func enabledBinding(for index: Int) -> Binding<Bool> {
        Binding {
            !chip.finger.disabledModes[index]
        } set: { enabled in
            chip.finger.disabledModes[index] = !enabled
        }
    }

    private func sequenceBinding(mode: Int, sequence: Int) -> Binding<LEDSequence> {
        Binding {
            chip.finger.modes[mode].sequences[sequence]
        } set: { updatedSequence in
            chip.finger.modes[mode].sequences[sequence] = updatedSequence
        }
    }
}

struct SequenceRow: View {
    var sequence: LEDSequence

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if !sequence.flashingPattern.imageName.isEmpty {
                    ResourceImage(name: sequence.flashingPattern.imageName)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                VStack(alignment: .leading) {
                    Text(sequence.flashingPattern.name)
                    Text("Pattern \(sequence.flashingPattern.code)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            HStack(spacing: 6) {
                ForEach(sequence.colorSet) { color in
                    Circle()
                        .fill(color.displayColor)
                        .stroke(.primary.opacity(color.disabled ? 0.35 : 0.08), lineWidth: 1)
                        .frame(width: 22, height: 22)
                        .accessibilityLabel(color.name)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


struct SequenceEditorView: View {
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService
    @Environment(\.dismiss) private var dismiss

    @Binding private var sequence: LEDSequence
    @State private var draft: LEDSequence
    let stockPatterns: [FlashingPattern]
    let customPatterns: [FlashingPattern]
    let stockColors: [LEDColor]
    let paletteColors: [LEDColor]

    init(
        sequence: Binding<LEDSequence>,
        stockPatterns: [FlashingPattern],
        customPatterns: [FlashingPattern],
        stockColors: [LEDColor],
        paletteColors: [LEDColor]
    ) {
        _sequence = sequence
        _draft = State(initialValue: sequence.wrappedValue)
        self.stockPatterns = stockPatterns
        self.customPatterns = customPatterns
        self.stockColors = stockColors
        self.paletteColors = paletteColors
    }

    var body: some View {
        List {
            Section("Flashing Pattern") {
                NavigationLink {
                    PatternSelectionView(
                        sequence: $draft,
                        stockPatterns: stockPatterns,
                        customPatterns: customPatterns
                    )
                } label: {
                    SequenceRow(sequence: draft)
                }
            }

            Section {
                ForEach(0..<draft.maxColors, id: \.self) { slot in
                    NavigationLink {
                        ColorSelectionView(
                            sequence: $draft,
                            requestedSlot: slot,
                            stockColors: stockColors,
                            paletteColors: paletteColors
                        )
                    } label: {
                        ColorSlotRow(sequence: draft, slot: slot)
                    }
                }
            } header: {
                Text("Colors")
            } footer: {
                Text("Choose a selected color again to cycle High, Medium, and Low brightness.")
            }

            Button {
                bluetooth.preview(draft)
            } label: {
                Label("Preview Sequence", systemImage: "play.circle")
            }
        }
        .navigationTitle("Configure Sequence")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    sequence = draft
                    dismiss()
                }
            }
        }
    }
}

private struct ColorSlotRow: View {
    let sequence: LEDSequence
    let slot: Int

    var body: some View {
        HStack {
            Text("Color \(slot + 1)")
            Spacer()
            if sequence.colorSet.indices.contains(slot) {
                let color = sequence.colorSet[slot]
                let tint = sequence.colorTints.indices.contains(slot) ? sequence.colorTints[slot] : .high
                Text(color.name)
                    .foregroundStyle(.secondary)
                if tint != .high && color.fixedColorRef != 1 {
                    Text(tint.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                Circle()
                    .fill(color.displayColor(tint: tint))
                    .stroke(.primary.opacity(0.1), lineWidth: 1)
                    .frame(width: 24, height: 24)
            } else {
                Text("Disabled")
                    .foregroundStyle(.secondary)
                Circle()
                    .stroke(.secondary, style: StrokeStyle(lineWidth: 1, dash: [3]))
                    .frame(width: 24, height: 24)
            }
        }
    }
}

private struct PatternSelectionView: View {
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService
    @Environment(\.dismiss) private var dismiss

    @Binding var sequence: LEDSequence
    @State private var selectedPattern: FlashingPattern
    @State private var selectedIsCustom: Bool
    let stockPatterns: [FlashingPattern]
    let customPatterns: [FlashingPattern]

    init(
        sequence: Binding<LEDSequence>,
        stockPatterns: [FlashingPattern],
        customPatterns: [FlashingPattern]
    ) {
        _sequence = sequence
        _selectedPattern = State(initialValue: sequence.wrappedValue.flashingPattern)
        _selectedIsCustom = State(initialValue: sequence.wrappedValue.customFlashingPattern)
        self.stockPatterns = stockPatterns
        self.customPatterns = customPatterns
    }

    var body: some View {
        List {
            patternSection("Classic Flashing Patterns", patterns: stockPatterns, custom: false)
            if !customPatterns.isEmpty {
                patternSection("Custom Flashing Patterns", patterns: customPatterns, custom: true)
            }
        }
        .navigationTitle("Select Pattern")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    sequence.flashingPattern = selectedPattern
                    sequence.customFlashingPattern = selectedIsCustom
                    dismiss()
                }
            }
        }
    }

    private func patternSection(
        _ title: String,
        patterns: [FlashingPattern],
        custom: Bool
    ) -> some View {
        Section(title) {
            ForEach(patterns) { pattern in
                Button {
                    selectedPattern = pattern
                    selectedIsCustom = custom
                    var preview = sequence
                    preview.flashingPattern = pattern
                    preview.customFlashingPattern = custom
                    bluetooth.preview(preview)
                } label: {
                    HStack {
                        PatternThumbnail(pattern: pattern)
                        VStack(alignment: .leading) {
                            Text(pattern.name)
                                .foregroundStyle(.primary)
                            Text("Pattern \(pattern.code)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedPattern.name == pattern.name && selectedIsCustom == custom {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
    }
}

private struct PatternThumbnail: View {
    let pattern: FlashingPattern

    var body: some View {
        Group {
            if pattern.imageName.isEmpty {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.quaternary)
                    .overlay(Text("\(pattern.code)").font(.caption.bold()))
            } else {
                ResourceImage(name: pattern.imageName)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
        }
        .frame(width: 48, height: 48)
    }
}

private struct ColorSelectionView: View {
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService
    @Environment(\.dismiss) private var dismiss

    @Binding var sequence: LEDSequence
    @State private var workingSequence: LEDSequence
    @State private var selectedColor: LEDColor?
    @State private var selectedTint: ColorTint
    let slot: Int
    let stockColors: [LEDColor]
    let paletteColors: [LEDColor]

    init(
        sequence: Binding<LEDSequence>,
        requestedSlot: Int,
        stockColors: [LEDColor],
        paletteColors: [LEDColor]
    ) {
        let value = sequence.wrappedValue
        let normalizedSlot = min(requestedSlot, value.colorSet.count)
        _sequence = sequence
        _workingSequence = State(initialValue: value)
        _selectedColor = State(initialValue: value.colorSet.indices.contains(normalizedSlot) ? value.colorSet[normalizedSlot] : nil)
        _selectedTint = State(initialValue: value.colorTints.indices.contains(normalizedSlot) ? value.colorTints[normalizedSlot] : .high)
        slot = normalizedSlot
        self.stockColors = stockColors
        self.paletteColors = paletteColors
    }

    private let columns = [GridItem(.adaptive(minimum: 88), spacing: 12)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                colorButton(.disabledColor, title: "Disabled")
                ForEach(stockColors) { color in
                    colorButton(color, title: color.name)
                }
            }
            .padding()

            if !paletteColors.isEmpty {
                Text("Default Palette")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(paletteColors) { color in
                        colorButton(color, title: color.name)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Color \(slot + 1)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    sequence = workingSequence
                    dismiss()
                }
            }
        }
    }

    private func colorButton(_ color: LEDColor, title: String) -> some View {
        let selected = color.disabled ? selectedColor == nil : selectedColor?.id == color.id
        return Button {
            select(color)
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(color.disabled ? Color.clear : color.displayColor(tint: selected ? selectedTint : .high))
                        .stroke(selected ? Color.accentColor : Color.secondary.opacity(0.35), lineWidth: selected ? 3 : 1)
                        .overlay {
                            if color.disabled {
                                Image(systemName: "nosign")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 54, height: 54)
                    if selected && !color.disabled && selectedTint != .high && color.fixedColorRef != 1 {
                        Text(selectedTint.rawValue)
                            .font(.caption2.bold())
                            .padding(4)
                            .background(.regularMaterial, in: Circle())
                    }
                }
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func select(_ color: LEDColor) {
        if color.disabled {
            selectedColor = nil
            selectedTint = .high
            removeColor()
        } else {
            let isBlank = color.fixedColorRef == 1
            if selectedColor?.id == color.id && !isBlank {
                selectedTint = selectedTint.next
            } else {
                selectedColor = color
                selectedTint = .high
            }
            setColor(color, tint: isBlank ? .high : selectedTint)
        }
        bluetooth.preview(workingSequence)
    }

    private func setColor(_ color: LEDColor, tint: ColorTint) {
        if workingSequence.colorSet.indices.contains(slot) {
            workingSequence.colorSet[slot] = color
        } else if slot < workingSequence.maxColors {
            workingSequence.colorSet.append(color)
        }
        while workingSequence.colorTints.count < workingSequence.colorSet.count {
            workingSequence.colorTints.append(.high)
        }
        if workingSequence.colorTints.indices.contains(slot) {
            workingSequence.colorTints[slot] = tint
        }
        trimTints()
    }

    private func removeColor() {
        if workingSequence.colorSet.indices.contains(slot) {
            workingSequence.colorSet.remove(at: slot)
        }
        if workingSequence.colorTints.indices.contains(slot) {
            workingSequence.colorTints.remove(at: slot)
        }
        trimTints()
    }

    private func trimTints() {
        if workingSequence.colorTints.count > workingSequence.colorSet.count {
            workingSequence.colorTints.removeLast(workingSequence.colorTints.count - workingSequence.colorSet.count)
        }
    }
}
