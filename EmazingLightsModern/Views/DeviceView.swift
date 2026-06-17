import SwiftUI

struct DeviceView: View {
    @EnvironmentObject private var store: ProgrammingStore
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService
    @State private var selectedHub: DiscoveredHub?

    var body: some View {
        NavigationStack {
            List {
                Section("Connection") {
                    LabeledContent("Bluetooth", value: bluetooth.bluetoothStateDescription)
                    LabeledContent("PhotoHub", value: bluetooth.connectionStatus)
                    LabeledContent("Sync", value: bluetooth.syncStatus)
                    if let hub = bluetooth.connectedHub {
                        LabeledContent("Connected", value: hub.name)
                    }
                }

                Section("Saved PhotoHubs") {
                    if store.knownHubs.isEmpty {
                        Text("No saved hubs")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(store.knownHubs) { hub in
                        Button {
                            bluetooth.connectKnownHub(hub)
                        } label: {
                            HStack {
                                Image(systemName: "memorychip")
                                VStack(alignment: .leading) {
                                    Text(hub.name)
                                    Text(hub.uuid)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }

                Section("Pairing") {
                    TextField("Hub name", text: $bluetooth.hubNameDraft)
                    HStack {
                        Button {
                            bluetooth.scanForPairingHubs()
                        } label: {
                            Label("Scan", systemImage: "magnifyingglass")
                        }
                        Button(role: .cancel) {
                            bluetooth.stopScan()
                        } label: {
                            Label("Stop", systemImage: "stop.circle")
                        }
                    }

                    ForEach(bluetooth.discoveredHubs) { hub in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(hub.name)
                                Text("\(hub.uuidString)  RSSI \(hub.rssi)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button {
                                bluetooth.pairAndName(hub, name: bluetooth.hubNameDraft)
                            } label: {
                                Image(systemName: "link.badge.plus")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Pair hub")
                        }
                    }
                }
            }
            .navigationTitle("Device Programming")
            .toolbar {
                Button {
                    bluetooth.disconnect()
                } label: {
                    Image(systemName: "xmark.circle")
                }
                .accessibilityLabel("Disconnect")
            }
        }
    }
}
