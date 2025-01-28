import SwiftUI
import Combine

class AppManager: ObservableObject {
    static let shared = AppManager()

    @Published var bleManager: BluetoothManager

    private init() {
        bleManager = BluetoothManager()
    }
}
