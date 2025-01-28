import SwiftUI
import Combine
import LiveViewNative
import CoreBluetooth

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
    
    /// A boolean indicating whether the client should start scanning for peripherals.
    @_documentation(visibility: public)
    private var scanForPeripherals: Bool = false

    /// A boolean indicating whether the client should stop scanning for peripherals.
    @_documentation(visibility: public)
    private var stopScan: Bool = false
    
    var body: some View {
        Text("BLEClient") // Start with an actual view
        // remote changes
            .onChange(of: scanForPeripherals) { newValue in
                if newValue {
                    print("scanForPeripherals ... ")
                    coordinator.startScan()
                }
            }
            .onChange(of: stopScan) {newValue in
                if newValue{
                    coordinator.stopScan()
                }
            }

        // setup
            .task {
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
