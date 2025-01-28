import SwiftUI
import LiveViewNative
import LiveViewNativeCore
import CoreBluetooth
import Combine


struct BLEClient: View {
    @Environment(\.customEnvironment) var customEnvironment // Correct access
    

    var body: some View {
           if let custom = customEnvironment {
              //BluetoothClient(bleManager: custom.bleManager)
           } else {
                Text("Error")
           }
    }
}

//extension BLEClient: LiveViewNativeComponent {
//    static var name: String = "BLEClient"
//}
