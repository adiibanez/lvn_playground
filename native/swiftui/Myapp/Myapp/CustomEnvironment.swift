import SwiftUI

struct CustomEnvironment {
  var bleManager: BluetoothManager
  var sendMessage: (String) -> Void
}
struct CustomEnvironmentKey: EnvironmentKey {
    static var defaultValue: CustomEnvironment?
}

extension EnvironmentValues {
    var customEnvironment: CustomEnvironment? {
        get { self[CustomEnvironmentKey.self] }
        set { self[CustomEnvironmentKey.self] = newValue }
    }
}
