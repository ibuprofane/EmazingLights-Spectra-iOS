import CoreBluetooth
import Foundation

class BluetoothDevice {
    let uuid: String
    var givenName: String
    var batteryLevel: Int = 0
    var deviceType: String
    weak var peripheral: CBPeripheral?
    var services: [String: CBService] = [:]
    var characteristics: [String: CBCharacteristic] = [:]

    init(peripheral: CBPeripheral, name: String, deviceType: String) {
        self.peripheral = peripheral
        self.givenName = name
        self.uuid = peripheral.identifier.uuidString
        self.deviceType = deviceType
    }

    init(uuid: String, name: String, deviceType: String) {
        self.uuid = uuid
        self.givenName = name
        self.deviceType = deviceType
    }

    func decodeBatteryLevel(from data: Data) {
        batteryLevel = data.withUnsafeBytes { buffer in
            guard let byte = buffer.first else { return 0 }
            return Int(byte)
        }
    }
}

final class PhotoHubDevice: BluetoothDevice {
    init(peripheral: CBPeripheral, name: String = DeviceConstants.photoHubDefaultDisplayName) {
        super.init(peripheral: peripheral, name: name, deviceType: DeviceConstants.photoHubHardwareName)
    }

    init(uuid: String, name: String) {
        super.init(uuid: uuid, name: name, deviceType: DeviceConstants.photoHubHardwareName)
    }
}
