import SwiftUI
import CoreBluetooth
import Combine

struct BluetoothClient: View {
    @EnvironmentObject var bleManager: BluetoothManager
    @State private var scannedDevices: [CBPeripheral] = []
    @State private var selectedDevice: CBPeripheral?
    @State private var selectedService: CBService?
    @State private var selectedCharacteristic: CBCharacteristic?
    
    var body: some View {
        VStack {
            Text("Scan Results")
                .font(.title)
            
            List {
                ForEach(bleManager.discoveredPeripherals.values.map { $0 }, id: \.self) { peripheral in
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
                            HStack {
                                Text("Services")
                                    .font(.subheadline)
                            }
                            List {
                                ForEach(bleManager.discoveredServices.values.map { $0 }, id: \.self) { service in
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
                                        HStack {
                                            Text("Characteristics")
                                                .font(.subheadline)
                                        }
                                        List {
                                            ForEach(bleManager.discoveredCharacteristics.values.map { $0 }, id: \.self) { characteristic in
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
                                        }
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
             HStack {
                    Button("Scan") {
                        print("Button tapped: Scan Peripherals")
                        bleManager.scanForPeripherals()
                        self.scannedDevices = bleManager.discoveredPeripherals.values.map {$0}
                        selectedDevice = nil
                        selectedService = nil
                        selectedCharacteristic = nil
                    }
                    .padding()
                    if let selected = selectedDevice {
                        Button("Connect") {
                            print("Button tapped: Connect Peripherals, Device: \(selected.name ?? "Unknown"), Service: \(selectedService?.uuid.uuidString ?? "None"), Characteristic: \(selectedCharacteristic?.uuid.uuidString ?? "None")")
                            bleManager.connect(peripheral: selected, serviceUUID: selectedService?.uuid, characteristicUUID: selectedCharacteristic?.uuid)
                        }
                        .padding()
                    }
                }
            
            
            Text("Connection State: \(bleManager.connectionState)")
                .font(.subheadline)
            
        }
        .onReceive(bleManager.objectWillChange) {
            print("Updating Scan results in the view")
            self.scannedDevices = bleManager.discoveredPeripherals.values.map {$0}
        }
    }
}
