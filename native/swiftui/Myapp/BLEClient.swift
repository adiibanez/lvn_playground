import SwiftUI
import LiveViewNative
import LiveViewNativeCore
import CoreBluetooth
import Combine


struct BLEClient: View {
    //@Environment(\.appManager) var appManager
    
    @StateObject var appManager = AppManager.shared
    
    //@_documentation(visibility: public)
    //@LiveElement
    //struct Map<Root: RootRegistry>: View {
//        @_documentation(visibility: public)
//        @LiveAttribute(.init(namespace: "bounds", name: "latitude")) private var boundsLatitude: Double?
        
        
            
  //  }
    
    var body: some View {
           //if let appManager = appManager {
           //  BluetoothClient(bleManager: appManager.bleManager)
           //} else {
                Text("Hello World BLEClient")
           //}
    }

    
}

//extension BLEClient: LiveViewNativeView {
//    static var name: String = "BLEClient"
//}
