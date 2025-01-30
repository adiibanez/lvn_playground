import SwiftUI
import Foundation
import Combine
import LiveViewNative
import CoreBluetooth
import LiveViewNativeCore
import LiveViewNativeCoreFFI

final class BLEClientCoordinator: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  @Published var dataUpdate: String = ""
    @Published var discoveredPeripherals: [UUID: CBPeripheral] = [:]
   @Published  var peripheralDisplayData: [PeripheralDisplayData] = []
    @Published var characteristics: [UUID: [CBUUID: CBCharacteristic]] = [:]

    let centralManager: CBCentralManager = .init()
    override init() {
        super.init()
    }

    func startScan(){
        centralManager.scanForPeripherals(withServices: nil)
    }

    func stopScan(){
        centralManager.stopScan()
    }
  
  func updatePeripheralDisplayData() {
          peripheralDisplayData = discoveredPeripherals.map { (key, peripheral) in
            PeripheralDisplayData(id: key, name: peripheral.name ?? "Unnamed", rssi: peripheral.rssi, state: peripheral.state)
              }.sorted(by: {$0.name < $1.name})
      }

    // MARK: - CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth is powered on")
        case .poweredOff:
            print("Bluetooth is powered off")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unsupported:
            print("Bluetooth is unsupported")
        case .unknown:
            print("Bluetooth is in an unknown state")
        @unknown default:
            print("Bluetooth is in an unknown state")
        }
    }

    func getPeripheralIdentifier(peripheral: CBPeripheral) -> String? {
        let identifierString = peripheral.identifier.uuidString
        return identifierString
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

         guard let name = peripheral.name, name.hasPrefix("Movesense") else{
            print("Ignoring peripheral \(peripheral.name ?? "Unnamed"), since does not start with Movesense")
            return
        }
          let prefixes = ["Movesense", "WH-", "PressureSensor", "FLexsense"]
       
          if let name = peripheral.name {
              if prefixes.contains(where: { name.hasPrefix($0) }) {
                 if let jsonData = try? JSONSerialization.data(withJSONObject: [
                      "peripheral_name": (peripheral.name ?? "Unnamed"),
                      "RSSI": RSSI,
                  ], options: []) {
                      dataUpdate = String(data: jsonData, encoding: .utf8) ?? ""
                  } else{
                       dataUpdate = "Error serializing data to JSON"
                  }
                    print("Discovered and connecting to peripheral: \(peripheral.name ?? "Unnamed"), RSSI: \(RSSI)")
                    self.discoveredPeripherals[peripheral.identifier] = peripheral
                    peripheral.delegate = self // SET DELEGATE BEFORE calling readRSSI()
                     Task{
                       await self.updateRSSI(peripheral: peripheral)
                       self.updatePeripheralDisplayData()
                     }
                    centralManager.stopScan()
                    centralManager.connect(peripheral, options: nil)
                  updatePeripheralDisplayData()
              }}
           else{
              if let jsonData = try? JSONSerialization.data(withJSONObject: ["peripheral_name": peripheral.name ?? "Unnamed", "RSSI": RSSI], options: []) {
                    dataUpdate = String(data: jsonData, encoding: .utf8) ?? ""
                } else{
                    dataUpdate = "Error serializing data to JSON"
                 }
               print("Discovered peripheral: \(peripheral.name ?? "Unnamed"), RSSI: \(RSSI), but not connecting to it.")
               updatePeripheralDisplayData()
           }
    }
  
  func updateRSSI(peripheral: CBPeripheral) async {
      peripheral.readRSSI() // call to readRSSI, the result will be returned in the delegate method
    }
  
     func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
         print("Connected to \(peripheral.name ?? "Unnamed")")
           Task{
             await self.discoverServices(peripheral: peripheral)
               updatePeripheralDisplayData()
           }
      }

    func discoverServices(peripheral: CBPeripheral) async {
        if peripheral.state == .connected { // Only when connected
            peripheral.discoverServices(nil)
        }
    }
  
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unnamed") with error: \(String(describing: error))")
        updatePeripheralDisplayData()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unnamed") with error: \(String(describing: error))")
        updatePeripheralDisplayData()
    }

    // MARK: - CBPeripheralDelegate
   func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
       if let error = error {
           print("Error reading RSSI for \(peripheral.name ?? "Unnamed"): \(error.localizedDescription)")
           peripheral.rssi = 0
        } else {
           print("RSSI Updated for \(peripheral.name ?? "Unnamed"): \(RSSI)")
             peripheral.rssi = RSSI.intValue
            updatePeripheralDisplayData()
        }
    }
  
  
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
          guard let services = peripheral.services else {return}
          for service in services {
                print("Discovered service: \(service)")
             Task{
               await discoverCharacteristics(peripheral: peripheral, service: service)
           }
          }
    }
    
  func discoverCharacteristics(peripheral: CBPeripheral, service: CBService) async {
        if peripheral.state == .connected { // Only when connected
              peripheral.discoverCharacteristics(nil, for: service)
        }
   }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
       guard let characteristics = service.characteristics else {return}

        for characteristic in characteristics {
            print("\(peripheral.name) Discovered characteristics: \(characteristic) \(BluetoothUtils.name(for: characteristic.uuid))")
            if characteristic.properties.contains(.notify){
                print("\(peripheral.name) Subscribing to characteristic \(characteristic)  \(BluetoothUtils.name(for: characteristic.uuid))")
               discoveredPeripherals[peripheral.identifier]?.setNotifyValue(true, for: characteristic)
                if self.characteristics[peripheral.identifier] == nil {
                    self.characteristics[peripheral.identifier] = [:]
                }
                self.characteristics[peripheral.identifier]?[characteristic.uuid] = characteristic
             } else{
                print("\(peripheral.name) not subscribing to characteristic \(characteristic)  \(BluetoothUtils.name(for: characteristic.uuid))")
           }
       }
   }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        if characteristic.uuid == CBUUID(string: "00002a37-0000-1000-8000-00805f9b34fb") { // Heart Rate Characteristic UUID
            
               if data.count > 0 {
                   let flags = data[0]
                   let heartRateFormatBit = flags & 0x01
                   var heartRateValue: UInt16 = 0

                  if heartRateFormatBit == 0 {
                        if data.count >= 2 {
                           heartRateValue = UInt16(data[1])
                        }
                    } else {
                        if data.count >= 3 {
                            heartRateValue = data.withUnsafeBytes { buffer in
                                let rawValue: UInt16 = buffer.load(fromByteOffset: 1, as: UInt16.self)
                                return UInt16(littleEndian: rawValue)
                            }
                        }
                    }

                    if let jsonData = try? JSONSerialization.data(withJSONObject: ["sensor_name": peripheral.name, "characteristic_uuid": characteristic.uuid.uuidString, "data": String(describing: heartRateValue)], options: []) {
                         dataUpdate = String(data: jsonData, encoding: .utf8) ?? ""
                   }
                   print("Received heart rate: \(heartRateValue) for char \(characteristic.uuid.uuidString)")
               }
               else {
                    print("Data is too short to read heartrate")
               }
         }
        else {
            guard let stringValue = String(data: data, encoding: .utf8) else{
                 print("Cannot decode data from  \(characteristic.uuid.uuidString)")
                 return
           }
            if let jsonData = try? JSONSerialization.data(withJSONObject: ["sensor_name": peripheral.name, "characteristic_uuid": characteristic.uuid.uuidString, "data": stringValue], options: []) {
                dataUpdate = String(data: jsonData, encoding: .utf8) ?? ""
             }
           print("Received value : \(stringValue) for char \(characteristic.uuid.uuidString)")
       }
    }
}

struct PeripheralDisplayData: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
    let state: CBPeripheralState
}

extension CBPeripheral {
    private struct AssociatedKeys {
      static var rssi: Int = 0
    }
    var rssi: Int {
        get {
          return (objc_getAssociatedObject(self, &AssociatedKeys.rssi) as? Int) ?? 0
        }
        set {
          objc_setAssociatedObject(self, &AssociatedKeys.rssi, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
      }
}
