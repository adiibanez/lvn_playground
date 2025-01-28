import SwiftUI

@main
struct Myapp: App {
    //@StateObject var bleManager = BluetoothManager() // Now we don't need to provide uuids
    
    var body: some Scene {
        WindowGroup {
           ContentView()
             //BluetoothClient()
            //.environmentObject(bleManager) // Inject the manager to the environment
        }
    }
}
