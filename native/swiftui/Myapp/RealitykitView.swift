import SwiftUI
import LiveViewNative
import LiveViewNativeRealityKit // 1. Import the add-on library.

struct RealitykitView: View {
    var body: some View {
        #LiveView(
            .localhost,
            addons: [.realityKit] // 2. Include the `.realityKit` addon.
        )
    }
}
