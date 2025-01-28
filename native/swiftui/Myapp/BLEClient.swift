import SwiftUI
import Combine
import LiveViewNative
import CoreBluetooth
import LiveViewNativeCore
import LiveViewNativeCoreFFI

/// A native Bluetooth Low Energy client view. It can be rendered in a LiveViewNative app using the `BLEClient` element.
///
/// ## Attributes
///  * ``scanForPeripherals``
///  * ``stopScan``
///
@_documentation(visibility: public)
@LiveElement
struct BLEClient<Root: RootRegistry>: View {
    @LiveElementIgnored
    @StateObject private var coordinator = BLEClientCoordinator()
    
    
    
    
    @_documentation(visibility: public)
    @LiveAttribute(.init(name: "phx-scan-devices"))
    private var scanForPeripherals: Bool = false
    
    /// A boolean indicating whether the client should stop scanning for peripherals.
    @_documentation(visibility: public)
    private var stopScan: Bool = false
    
    var body: some View {
        
        VStack() {
            Text("Hello BLE")// Start with an actual view
            $liveElement.children()
        }
        // remote changes
        .onChange(of: scanForPeripherals) { newValue in
            
            print("scanForPeripherals 1 ... ")
            if newValue {
                print("scanForPeripherals 2 ... ")
                coordinator.startScan()
            }
        }
        .onChange(of: stopScan) {newValue in
            if newValue{
                coordinator.stopScan()
            }
        }
        .onChange(of: coordinator.centralManager.isScanning) {
            Task {
                // send a change event without automatic debouncing, the observer handles the debounce instead.
                try await $liveElement.context.coordinator.pushEvent(
                    type: "click",
                    event: "test-event",
                    value: ["is_scanning": true],
                    target: $liveElement.element.attributeValue(for: "phx-target").flatMap(Int.init)
                )
            }
        }.onTapGesture {
            print("TapGesture: Start scan ... ")
            coordinator.centralManager.scanForPeripherals(withServices: nil)
            
            Task {try await $liveElement.context.coordinator.pushEvent(
                type: "click",
                event: "test-event2",
                value: ["onTapGesture": true],
                target: $liveElement.element.attributeValue(for: "phx-target").flatMap(Int.init)
            )
            }
        }.onLongPressGesture {
            print("LongPressGesture: Stop scan ... ")
            coordinator.centralManager.stopScan()
            Task {
                try await $liveElement.context.coordinator.pushEvent(
                    type: "click",
                    event: "test-event2",
                    value: ["onLongPressGestrue": true],
                    target: $liveElement.element.attributeValue(for: "phx-target").flatMap(Int.init)
                )
            }
        }
        
        // setup
        .task {
            
            //$liveElement.context.coordinator.handleEvent("ble-command") { (payload: Any) in
             //   print("Hello ... ble-command")
            //}
            // payload: Dictionary<String, Any>
            $liveElement.context.coordinator.handleEvent("ble-command") { (payload: [String: Any]) in
              print("Testlitest")
            }
        
            coordinator.centralManager.delegate = coordinator
        }
    }
    
    /// An observer for a `BLEClient` that manages the `CBCentralManager` instance
    final class BLEClientCoordinator: NSObject, ObservableObject, CBCentralManagerDelegate {
        
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
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            print("Discovered peripheral: \(peripheral.name ?? "Unnamed"), RSSI: \(RSSI)")
        }
        
    }
}
