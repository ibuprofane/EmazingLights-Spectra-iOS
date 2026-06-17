import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var store: ProgrammingStore
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService

    var body: some View {
        NavigationStack {
            List {
                Section("Runtime") {
                    LabeledContent("Bluetooth", value: bluetooth.bluetoothStateDescription)
                    LabeledContent("Connection", value: bluetooth.connectionStatus)
                    LabeledContent("Sync", value: bluetooth.syncStatus)
                    LabeledContent("Known Hubs", value: "\(store.knownHubs.count)")
                }

                Section("Last Payload") {
                    if bluetooth.lastCommands.isEmpty {
                        Text("No commands sent")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(bluetooth.lastCommands.prefix(24)) { command in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(command.characteristicID)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(command.hexDescription)
                                    .font(.system(.caption, design: .monospaced))
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }

                Section("Color Preview") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 88))], spacing: 10) {
                        ForEach(store.catalog.stockColors) { color in
                            Button {
                                bluetooth.previewColor(color)
                            } label: {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(color.swiftUIColor)
                                        .frame(width: 28, height: 28)
                                    Text(color.name)
                                        .font(.caption2)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, minHeight: 66)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Status")
        }
    }
}
