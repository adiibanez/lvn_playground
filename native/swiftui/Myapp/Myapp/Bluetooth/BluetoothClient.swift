import SwiftUI
import CoreBluetooth
import Combine

struct BluetoothClient: View {
    @EnvironmentObject var bleManager: BluetoothManager
    @State private var scannedDevices: [CBPeripheral] = []
    @State private var selectedDevice: CBPeripheral?
    @State private var selectedService: CBService?
    @State private var selectedCharacteristic: CBCharacteristic?
    @State private var isScanning: Bool = false
    

    var body: some View {
        VStack {
            Text("Scan Results")
                .font(.title)
            
            List {
                ForEach(bleManager.discoveredPeripherals.values.map { $0 }, id: \.self) { peripheral in
                    peripheralView(peripheral: peripheral)
                }
            }
            
            controlsView()
            
            Text("Connection State: \(bleManager.connectionState)")
                .font(.subheadline)
        }
        .onReceive(bleManager.objectWillChange) {
             print("Updating scan results")
           self.scannedDevices = bleManager.discoveredPeripherals.values.map {$0}
           if !bleManager.isScanning {
               isScanning = false
           }
        }
    }
    
    //MARK: Helper Views

    private func peripheralView(peripheral: CBPeripheral) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(peripheral.name ?? "Unknown Device")
                    .onTapGesture {
                        print("Device Tapped: \(peripheral.name ?? "Unknown"), UUID: \(peripheral.identifier)")
                        selectedDevice = peripheral
                        selectedService = nil
                        selectedCharacteristic = nil
                    }
                    .background(selectedDevice == peripheral ? Color.gray.opacity(0.3) : Color.clear)
            }
            if selectedDevice == peripheral {
                servicesView(peripheral: peripheral)
            }
             if bleManager.connectedPeripheral == peripheral {
               connectedCharacteristicsView(peripheral: peripheral)
            }
        }
    }
    
    private func servicesView(peripheral: CBPeripheral) -> some View {
        VStack {
            HStack {
                Text("Services")
                    .font(.subheadline)
            }
            List {
                ForEach(bleManager.discoveredServices.values.map { $0 }, id: \.self) { service in
                    serviceView(service: service)
                }
            }
        }
    }
    
     private func serviceView(service: CBService) -> some View {
         VStack {
              HStack {
                  Text(service.uuid.uuidString)
                     .onTapGesture {
                         print("Service Tapped: \(service.uuid.uuidString)")
                         selectedService = service
                         selectedCharacteristic = nil
                   }
                   .background(selectedService == service ? Color.gray.opacity(0.3) : Color.clear)
                   .font(.caption)
              }
              if selectedService == service {
                 characteristicsView()
            }
         }
     }
    
    private func characteristicsView() -> some View {
        VStack {
            HStack {
                Text("Characteristics")
                   .font(.subheadline)
            }
            List {
                ForEach(bleManager.discoveredCharacteristics.values.map { $0 }, id: \.self) { characteristic in
                 characteristicView(characteristic: characteristic)
               }
            }
       }
    }
    
    private func characteristicView(characteristic: CBCharacteristic) -> some View {
      HStack {
              Text(characteristic.uuid.uuidString)
                .onTapGesture {
                  print("Characteristic Tapped: \(characteristic.uuid.uuidString)")
                    selectedCharacteristic = characteristic
              }
                .background(selectedCharacteristic == characteristic ? Color.gray.opacity(0.3) : Color.clear)
                  .font(.caption)
       }
    }
   private func connectedCharacteristicsView(peripheral: CBPeripheral) -> some View {
    VStack {
      HStack {
            Text("Connected Characteristics")
              .font(.subheadline)
          }
        List {
           ForEach(bleManager.discoveredCharacteristics.values.map { $0 }, id: \.self) { characteristic in
               HStack {
                   Text(characteristic.uuid.uuidString)
                     .font(.caption)
               }
            }
        }
     }
    }

    
    private func controlsView() -> some View {
       HStack {
            Button(isScanning ? "Stop Scan" : "Scan") {
                if isScanning {
                    print("Button tapped: Stop Scan")
                    bleManager.stopScan()
                    isScanning = false
                } else {
                     print("Button Tapped: Scan Peripherals")
                    bleManager.scanForPeripherals()
                    self.scannedDevices = bleManager.discoveredPeripherals.values.map {$0}
                    selectedDevice = nil
                    selectedService = nil
                    selectedCharacteristic = nil
                     isScanning = true
                }
            }
            .padding()
            
            if let selected = selectedDevice {
                 Button("Connect") {
                     print("Button Tapped: Connect, Device: \(selected.name ?? "Unknown"), Service: \(selectedService?.uuid.uuidString ?? "None"), Characteristic: \(selectedCharacteristic?.uuid.uuidString ?? "None")")
                     bleManager.connect(peripheral: selected, serviceUUID: selectedService?.uuid, characteristicUUID: selectedCharacteristic?.uuid)
                 }
                .padding()
            }
            
           if bleManager.connectedPeripheral != nil {
               Button("Disconnect") {
                   print("Button Tapped: Disconnect")
                  bleManager.disconnect()
                     selectedDevice = nil
                    selectedService = nil
                  selectedCharacteristic = nil
               }
              .padding()
           }
        }
    }
}
