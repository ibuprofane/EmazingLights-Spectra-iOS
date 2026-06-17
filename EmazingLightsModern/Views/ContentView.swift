import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DeviceView()
                .tabItem {
                    Label("Devices", systemImage: "dot.radiowaves.left.and.right")
                }

            ProgramLibraryView()
                .tabItem {
                    Label("Programs", systemImage: "slider.horizontal.3")
                }

            PatternLibraryView()
                .tabItem {
                    Label("Patterns", systemImage: "square.grid.3x3")
                }

            StatusView()
                .tabItem {
                    Label("Status", systemImage: "waveform.path.ecg")
                }
        }
    }
}
