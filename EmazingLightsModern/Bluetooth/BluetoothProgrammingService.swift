@preconcurrency import CoreBluetooth
import Foundation

@MainActor
final class BluetoothProgrammingService: NSObject, ObservableObject {
    enum ScanIntent {
        case pairing
        case known(uuid: String)
    }

    @Published private(set) var bluetoothStateDescription = "Starting Bluetooth"
    @Published private(set) var connectionStatus = "Disconnected"
    @Published private(set) var syncStatus = "Idle"
    @Published private(set) var discoveredHubs: [DiscoveredHub] = []
    @Published private(set) var connectedHub: DiscoveredHub?
    @Published private(set) var lastCommands: [BLECommand] = []
    @Published var hubNameDraft = DeviceConstants.photoHubDefaultDisplayName

    private lazy var manager = CBCentralManager(delegate: self, queue: nil)
    private let payloadBuilder = ProgrammingPayloadBuilder()
    private var activeIntent: ScanIntent?
    private var connectedDevice: PhotoHubDevice?
    private var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var pendingPayload: [BLECommand] = []
    private var readyAfterDiscovery = false
    private var timeoutTask: Task<Void, Never>?
    private weak var store: ProgrammingStore?

    init(store: ProgrammingStore? = nil) {
        self.store = store
        super.init()
        _ = manager
    }

    func attachStore(_ store: ProgrammingStore) {
        self.store = store
    }

    func scanForPairingHubs() {
        startScan(intent: .pairing)
    }

    func connectKnownHub(_ hub: KnownHub) {
        hubNameDraft = hub.name
        startScan(intent: .known(uuid: hub.uuid))
    }

    func connect(_ hub: DiscoveredHub) {
        guard let peripheral = discoveredPeripherals[hub.id] ?? manager.retrievePeripherals(withIdentifiers: [hub.id]).first else {
            connectionStatus = "Unable to retrieve peripheral"
            return
        }
        stopScan()
        connectedHub = hub
        let device = PhotoHubDevice(peripheral: peripheral, name: hub.name)
        connectedDevice = device
        peripheral.delegate = self
        connectionStatus = "Connecting to \(hub.name)"
        manager.connect(peripheral, options: nil)
    }

    func disconnect() {
        pendingPayload = []
        readyAfterDiscovery = false
        timeoutTask?.cancel()
        guard let peripheral = connectedDevice?.peripheral else {
            connectionStatus = "Disconnected"
            connectedHub = nil
            return
        }
        manager.cancelPeripheralConnection(peripheral)
    }

    func pairAndName(_ hub: DiscoveredHub, name: String) {
        pendingPayload = payloadBuilder.renameHubAndExitPairing(name: name)
        readyAfterDiscovery = true
        hubNameDraft = name
        connect(hub)
    }

    func sync(_ chip: ChipProgram) {
        pendingPayload = payloadBuilder.fullChipSync(for: chip)
        sendWhenReady(status: "Syncing \(chip.name)")
    }

    func preview(_ sequence: LEDSequence) {
        pendingPayload = payloadBuilder.previewSequence(sequence)
        sendWhenReady(status: "Previewing \(sequence.flashingPattern.name)")
    }

    func previewPattern(_ pattern: FlashingPattern) {
        pendingPayload = payloadBuilder.previewPattern(id: pattern.code)
        sendWhenReady(status: "Previewing \(pattern.name)")
    }

    func previewColor(_ color: LEDColor) {
        pendingPayload = payloadBuilder.enableCustomColorPreviewMode() + payloadBuilder.previewCustomColor(color)
        sendWhenReady(status: "Previewing \(color.name)")
    }

    func stopScan() {
        activeIntent = nil
        manager.stopScan()
        timeoutTask?.cancel()
    }

    private func startScan(intent: ScanIntent) {
        guard manager.state == .poweredOn else {
            connectionStatus = "Bluetooth is not ready"
            return
        }
        timeoutTask?.cancel()
        activeIntent = intent
        discoveredHubs = []
        discoveredPeripherals = [:]
        switch intent {
        case .pairing:
            connectionStatus = "Scanning for pairing hubs"
        case .known:
            connectionStatus = "Scanning for saved hub"
        }
        manager.stopScan()
        manager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        timeoutTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(10))
            await MainActor.run {
                self?.scanTimedOut()
            }
        }
    }

    private func scanTimedOut() {
        guard activeIntent != nil else { return }
        manager.stopScan()
        activeIntent = nil
        connectionStatus = "Timed out"
    }

    private func sendWhenReady(status: String) {
        guard connectedDevice?.peripheral != nil else {
            syncStatus = "Connect a PhotoHub first"
            return
        }
        syncStatus = status
        if hasCommandCharacteristic {
            Task { await writePendingPayload() }
        } else {
            readyAfterDiscovery = true
            connectedDevice?.peripheral?.discoverServices(nil)
        }
    }

    private var hasCommandCharacteristic: Bool {
        connectedDevice?.characteristics[BLECharacteristicID.gloveCommand] != nil
    }

    private func writePendingPayload() async {
        guard let device = connectedDevice, let peripheral = device.peripheral else {
            syncStatus = "No connected hub"
            return
        }

        let commands = pendingPayload
        pendingPayload = []
        readyAfterDiscovery = false
        lastCommands = commands

        for command in commands {
            guard let characteristic = device.characteristics[command.characteristicID] else {
                syncStatus = "Missing characteristic \(command.characteristicID)"
                return
            }
            write(command.data, to: characteristic, on: peripheral)
            try? await Task.sleep(for: .milliseconds(50))
        }

        if commands.contains(where: { $0.characteristicID == BLECharacteristicID.gloveName }) {
            if let hub = connectedHub {
                store?.rememberHub(uuid: hub.uuidString, name: hubNameDraft)
            }
            connectionStatus = "Paired"
        }
        syncStatus = "Finished"
    }

    private func write(_ data: Data, to characteristic: CBCharacteristic, on peripheral: CBPeripheral) {
        let writeType: CBCharacteristicWriteType
        if characteristic.properties.contains(.writeWithoutResponse) {
            writeType = .withoutResponse
        } else if characteristic.properties.contains(.write) {
            writeType = .withResponse
        } else {
            syncStatus = "Characteristic is not writable"
            return
        }

        if data.count <= 20 {
            peripheral.writeValue(data, for: characteristic, type: writeType)
        } else {
            for start in stride(from: 0, to: data.count, by: 20) {
                peripheral.writeValue(data.subdata(in: start..<min(start + 20, data.count)), for: characteristic, type: writeType)
            }
        }
    }

    private nonisolated static func parseAdvertisement(_ advertisementData: [String: Any]) -> (name: String, pairingMode: Bool)? {
        let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? DeviceConstants.photoHubDefaultDisplayName
        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return nil
        }

        let hubHeader = Data([0x45, 0x4C, 0x48, 0x55, 0x42, 0x31])
        guard manufacturerData.starts(with: hubHeader) else { return nil }
        return (name, manufacturerData.last == 0x01)
    }

    private nonisolated static func shouldAccept(peripheral: CBPeripheral, advertisementData: [String: Any]) -> (name: String, pairingMode: Bool)? {
        let parsed = parseAdvertisement(advertisementData)
        let advertisedName = parsed?.name ?? peripheral.name ?? DeviceConstants.photoHubDefaultDisplayName
        let nameLooksRight = peripheral.name == DeviceConstants.photoHubHardwareName || peripheral.name == DeviceConstants.photoHubFallbackName
        guard parsed != nil || nameLooksRight else { return nil }
        return (advertisedName, parsed?.pairingMode ?? false)
    }
}

extension BluetoothProgrammingService: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            switch central.state {
            case .poweredOn:
                bluetoothStateDescription = "Powered on"
            case .poweredOff:
                bluetoothStateDescription = "Powered off"
            case .unsupported:
                bluetoothStateDescription = "Bluetooth LE unsupported"
            case .unauthorized:
                bluetoothStateDescription = "Bluetooth unauthorized"
            case .resetting:
                bluetoothStateDescription = "Resetting"
            case .unknown:
                bluetoothStateDescription = "Unknown"
            @unknown default:
                bluetoothStateDescription = "Unavailable"
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        guard let accepted = Self.shouldAccept(peripheral: peripheral, advertisementData: advertisementData) else { return }
        let peripheralID = peripheral.identifier
        let peripheralUUID = peripheral.identifier.uuidString
        let rssi = RSSI.intValue

        Task { @MainActor in
            discoveredPeripherals[peripheralID] = peripheral

            switch activeIntent {
            case .pairing:
                guard accepted.pairingMode else { return }
                let hub = DiscoveredHub(
                    id: peripheralID,
                    uuidString: peripheralUUID,
                    name: accepted.name,
                    isPairingMode: accepted.pairingMode,
                    rssi: rssi
                )
                if !discoveredHubs.contains(where: { $0.id == hub.id }) {
                    discoveredHubs.append(hub)
                }
            case .known(let uuid):
                guard peripheralUUID == uuid else { return }
                let hub = DiscoveredHub(id: peripheralID, uuidString: uuid, name: accepted.name, isPairingMode: false, rssi: rssi)
                connect(hub)
            case nil:
                break
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            connectionStatus = "Connected"
            timeoutTask?.cancel()
            connectedHub = DiscoveredHub(
                id: peripheral.identifier,
                uuidString: peripheral.identifier.uuidString,
                name: connectedDevice?.givenName ?? peripheral.name ?? DeviceConstants.photoHubDefaultDisplayName,
                isPairingMode: false,
                rssi: 0
            )
            peripheral.discoverServices(nil)
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            connectionStatus = "Disconnected"
            syncStatus = error?.localizedDescription ?? "Idle"
            connectedHub = nil
            connectedDevice = nil
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Task { @MainActor in
            connectionStatus = error?.localizedDescription ?? "Failed to connect"
        }
    }
}

extension BluetoothProgrammingService: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        Task { @MainActor in
            if let error {
                connectionStatus = error.localizedDescription
                return
            }
            peripheral.services?.forEach { service in
                connectedDevice?.services[service.uuid.uuidString] = service
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        Task { @MainActor in
            if let error {
                connectionStatus = error.localizedDescription
                return
            }
            service.characteristics?.forEach { characteristic in
                connectedDevice?.characteristics[characteristic.uuid.uuidString] = characteristic
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
            }

            if readyAfterDiscovery, hasCommandCharacteristic {
                await writePendingPayload()
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        Task { @MainActor in
            guard error == nil, let data = characteristic.value else { return }
            if characteristic.uuid.uuidString == BLECharacteristicID.batteryLevel {
                connectedDevice?.decodeBatteryLevel(from: data)
            }
        }
    }
}
