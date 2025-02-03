import SwiftUI
import Foundation
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

      @State private var isConnecting = false

    var body: some View {
        NavigationView { // Added NavigationView
          VStack() {
            Text("Hello BLE")
                List {
                   Text("List of devices ...")
                       ForEach(coordinator.peripheralDisplayData) { peripheral in
                           Text("Peripheral: \(peripheral.name), RSSI: \(peripheral.rssi), Status: \(peripheralStateString(state: peripheral.state))")
                           
                           /*NavigationLink {
                               CharacteristicsView(peripheral: discoveredPeripherals(peripheralId: peripheral.id)!, coordinator: coordinator, isConnecting: $isConnecting) // Navigate to CharacteristicsView
                           } label: {
                               Text("Peripheral: \(peripheral.name), RSSI: \(peripheral.rssi), Status: \(peripheralStateString(state: peripheral.state))")
                            }*/
                        }
                    }
                $liveElement.children()
              }
          .navigationTitle("Discovered Devices") // Added navigation title
        }
        // remote changes
        .onChange(of: scanForPeripherals) {
            if scanForPeripherals == true {
                print("scanForPeripherals true ")
                coordinator.startScan()
            }
            
            if scanForPeripherals == false {
                print("scanForPeripherals false ")
                coordinator.stopScan()
            }
        }
        .onChange(of: coordinator.dataUpdate) {
            
            print("Data update: " + coordinator.dataUpdate)
            Task {
                try await $liveElement.context.coordinator.pushEvent(
                    type: "click",
                    event: "ble-response",
                    value: ["response": coordinator.dataUpdate],
                    target: $liveElement.element.attributeValue(for: "phx-target").flatMap(Int.init)
                )
            }
        }
        .onChange(of: coordinator.centralManager.isScanning) {
            Task {
                try await $liveElement.context.coordinator.pushEvent(
                    type: "click",
                    event: "test-event",
                    value: ["is_scanning": coordinator.centralManager.isScanning],
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
        }.onReceive($liveElement.context.coordinator.receiveEvent("ble-command")) { (payload: [String: Any]) in
            print("Testlitest")
        }
        
        // setup
        .task {
            coordinator.centralManager.delegate = coordinator
        }
        .task{
           coordinator.updatePeripheralDisplayData()
        }
    }
    
   func discoveredPeripherals(peripheralId: UUID) -> CBPeripheral?{
        return coordinator.discoveredPeripherals[peripheralId]
    }
    
    func peripheralStateString(state: CBPeripheralState) -> String {
           switch state {
           case .disconnected:
              return "Disconnected"
           case .disconnecting:
               return "Disconnecting"
           case .connected:
               return "Connected"
           case .connecting:
               return "Connecting"
           default:
               return "..."
           }
       }
}
