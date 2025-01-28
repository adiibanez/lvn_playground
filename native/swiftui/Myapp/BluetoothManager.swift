import SwiftUI
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    public var connectedPeripheral: CBPeripheral?
    @Published internal var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    @Published var connectionState: String = "Disconnected"
    @Published var sensorData: String = "No Data"
    var sendData: ((String) -> Void)?
    
    @Published var discoveredServices: [CBUUID: CBService] = [:]
    @Published var discoveredCharacteristics: [CBUUID: CBCharacteristic] = [:]
    
    private var serviceUUID: CBUUID?
    private var characteristicUUID: CBUUID?
    
     var isScanning: Bool {
           centralManager?.isScanning ?? false
        }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.connectionState = "Bluetooth Enabled. Ready to connect."
            //scanForPeripherals()
        case .poweredOff:
            self.connectionState = "Bluetooth is Off"
        case .unauthorized:
            self.connectionState = "Bluetooth Unauthorized"
        case .unsupported:
            self.connectionState = "Bluetooth Unsupported"
        case .unknown:
            self.connectionState = "Bluetooth Unknown State"
        case .resetting:
            self.connectionState = "Bluetooth Resetting"
        @unknown default:
            self.connectionState = "Unknown"
        }
    }
    
    func scanForPeripherals() {
        guard centralManager.state == .poweredOn else {
            print("Central manager not powered on")
            return
        }
        print("Scanning for peripherals...")
        discoveredPeripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil, options: nil) // Scan all services
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral.name ?? "Unknown Device")")
        discoveredPeripherals[peripheral.identifier] = peripheral
        
    }
    
    func connect(peripheral: CBPeripheral, serviceUUID: CBUUID? = nil, characteristicUUID: CBUUID? = nil) {
        print("Attempting to connect to \(peripheral.name ?? "Unknown Device")")
        centralManager.stopScan()
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        self.serviceUUID = serviceUUID
        self.characteristicUUID = characteristicUUID
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected to: \(peripheral.name ?? "Unknown Device")")
        self.connectionState = "Connected"
        if let serviceUUID = serviceUUID {
            peripheral.discoverServices([serviceUUID])
        } else {
            peripheral.discoverServices(nil) //discover all services
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to: \(peripheral.name ?? "Unknown Device") with error: \(String(describing: error?.localizedDescription))")
        self.connectionState = "Failed to connect"
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown Device") with error: \(String(describing: error?.localizedDescription))")
        self.connectionState = "Disconnected"
    }
    
    // MARK: - Peripheral Delegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        print("Discovered Services!")
        self.discoveredServices = [:] //Clear discovered services
        if let services = peripheral.services {
            for service in services {
                self.discoveredServices[service.uuid] = service
                if let characteristicUUID = characteristicUUID {
                    peripheral.discoverCharacteristics([characteristicUUID], for: service)
                } else {
                    peripheral.discoverCharacteristics(nil, for: service) // discover all characteristics
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        print("Discovered characteristics")
        self.discoveredCharacteristics = [:] // Clear discovered characteristics
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                self.discoveredCharacteristics[characteristic.uuid] = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading value: \(error.localizedDescription)")
            return
        }
        
        guard let value = characteristic.value else {
            print("No data")
            return
        }
        let strValue = String(data: value, encoding: .utf8) ?? "No String Data"
        self.sensorData = strValue
        self.sendData?(strValue)
    }
    
    func disconnect() {
        guard let peripheral = connectedPeripheral else {
            print("No peripheral connected.")
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
        self.connectedPeripheral = nil
        self.connectionState = "Disconnected"
        self.discoveredServices = [:]
        self.discoveredCharacteristics = [:]
        
    }
    
    func stopScan() {
      centralManager.stopScan()
    }
}
