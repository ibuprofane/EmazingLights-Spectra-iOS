import SwiftUI

struct ProgramLibraryView: View {
    @EnvironmentObject private var store: ProgrammingStore

    var body: some View {
        NavigationStack {
            List(store.chips) { chip in
                NavigationLink {
                    ChipDetailView(chip: chip)
                } label: {
                    HStack(spacing: 12) {
                        ResourceImage(name: chip.imageName)
                            .frame(width: 52, height: 52)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(chip.name)
                                .font(.headline)
                            Text(chip.tags.sorted().joined(separator: " / "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }
            .navigationTitle("Programs")
        }
    }
}

struct ChipDetailView: View {
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService
    @State var chip: ChipProgram

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
                        SequenceRow(sequence: mode.sequences[sequenceIndex]) {
                            bluetooth.preview(mode.sequences[sequenceIndex])
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
}

struct SequenceRow: View {
    var sequence: LEDSequence
    var preview: () -> Void

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
                Button(action: preview) {
                    Image(systemName: "play.circle")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Preview sequence")
            }
            HStack(spacing: 6) {
                ForEach(sequence.colorSet) { color in
                    Circle()
                        .fill(color.swiftUIColor)
                        .stroke(.primary.opacity(color.disabled ? 0.35 : 0.08), lineWidth: 1)
                        .frame(width: 22, height: 22)
                        .accessibilityLabel(color.name)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
