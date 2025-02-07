import SwiftUI
import Foundation
import Combine
import LiveViewNative
import CoreBluetooth
import LiveViewNativeCore
/*
struct CharacteristicsView: View {
    @ObservedObject var coordinator: BLEClientCoordinator
    let peripheral: CBPeripheral
    @Binding var isConnecting: Bool

    var body: some View {
        VStack {
            Text("Characteristics for \(peripheral.name ?? "Unnamed")")
            List {
                ForEach(peripheral.characteristics?.sorted(by: { $0.value.uuid.uuidString < $1.value.uuid.uuidString }) ?? [], id: \.key) {  uuid, characteristic  in
                     Text("\(BluetoothUtils.name(for: characteristic.uuid)): \(characteristic.uuid.uuidString)")
                }
             }
            Button(isConnecting ? "Connecting..." : "Connect to \(peripheral.name ?? "Unnamed")"){
                isConnecting = true
                Task {
                    try await coordinator.centralManager.connect(peripheral, options: nil)
                    // Push a 'connect' event to LiveView
                     /*try await coordinator.pushBleConnectEvent(
                         $liveElement.context.coordinator,
                         peripheralName: peripheral.name ?? "Unnamed",
                         target: $liveElement.element.attributeValue(for: "phx-target").flatMap(Int.init)
                     )
                      */
                    isConnecting = false
                      
                }
                
            }.disabled(isConnecting)
        }
        .navigationTitle("Characteristics") // CHANGED HERE

    }
}*/

/*extension BLEClientCoordinator {
    func pushBleConnectEvent(_ coordinator: LiveViewNativeCore.LiveViewCoordinator, peripheralName: String, target: Int?) async throws {
        try await coordinator.pushEvent(
             type: "click",
             event: "ble-connect",
             value: ["connect": true, "peripheral_name": peripheralName],
             target: target
          )
    }
}*/
