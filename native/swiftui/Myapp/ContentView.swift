import SwiftUI
import LiveViewNative
import LiveViewNativeLiveForm
import LiveViewNativeCore
import Combine
import CoreBluetooth

struct ContentView: View {
    @EnvironmentObject var bleManager: BluetoothManager
    @State private var messageFromBle: String = "No Message"
//    @Environment(\.liveViewNativeBridge) private var bridge

    var body: some View {
        #LiveView(
            .automatic(
                development: .localhost(path: "/"),
                production: URL(string: "https://example.com")!
            ),
           addons: [.liveForm]
        ) {
            ConnectingView()
        } disconnected: {
            DisconnectedView()
        } reconnecting: { content, isReconnecting in
            ReconnectingView(isReconnecting: isReconnecting) {
                content
            }
        } error: { error in
            ErrorView(error: error)
        }
        .environment(\.customEnvironment, CustomEnvironment(bleManager: bleManager, sendMessage: sendMessageToLV) )
        .onAppear {
             self.bleManager.sendData = { data in
              self.messageFromBle = data
                  self.sendMessageToLV(data: data)
           }
        }
    }

  func sendMessageToLV(data: String) {
    // Send BLE data to LiveView server
 //     bridge?.sendEvent("ble_data", payload: ["data": data])
  }
}
