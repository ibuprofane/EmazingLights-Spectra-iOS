import SwiftUI

@main
struct EmazingLightsModernApp: App {
    @StateObject private var store = ProgrammingStore()
    @StateObject private var bluetooth = BluetoothProgrammingService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(bluetooth)
                .task {
                    bluetooth.attachStore(store)
                }
        }
    }
}
