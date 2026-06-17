import SwiftUI

struct PatternLibraryView: View {
    @EnvironmentObject private var store: ProgrammingStore
    @EnvironmentObject private var bluetooth: BluetoothProgrammingService

    private let columns = [
        GridItem(.adaptive(minimum: 118), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.flashingPatterns) { pattern in
                        PatternCard(pattern: pattern) {
                            bluetooth.previewPattern(pattern)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Patterns")
        }
    }
}

struct PatternCard: View {
    var pattern: FlashingPattern
    var preview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if pattern.imageName.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary)
                    Text("\(pattern.code)")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                }
                .aspectRatio(1, contentMode: .fit)
            } else {
                ResourceImage(name: pattern.imageName)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(pattern.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                    Text("Code \(pattern.code)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: preview) {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.bordered)
                .accessibilityLabel("Preview \(pattern.name)")
            }
        }
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
