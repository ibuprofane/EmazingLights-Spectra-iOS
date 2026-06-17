import Foundation

@MainActor
final class ProgrammingStore: ObservableObject {
    @Published var catalog: ProgrammingCatalog {
        didSet { saveCatalog() }
    }
    @Published var knownHubs: [KnownHub] {
        didSet { saveKnownHubs() }
    }

    private let knownHubsKey = "known_photo_hubs"
    private let catalogKey = "programming_catalog"

    init() {
        catalog = Self.loadCatalog(key: catalogKey) ?? StockProgrammingCatalog.make()
        knownHubs = Self.loadKnownHubs(key: knownHubsKey)
    }

    var chips: [ChipProgram] {
        catalog.stockChips + catalog.customChips
    }

    var flashingPatterns: [FlashingPattern] {
        catalog.stockFlashingPatterns + catalog.customFlashingPatterns
    }

    func rememberHub(uuid: String, name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = trimmedName.isEmpty ? DeviceConstants.photoHubDefaultDisplayName : trimmedName
        let hub = KnownHub(uuid: uuid, name: displayName)
        if let index = knownHubs.firstIndex(where: { $0.uuid == uuid }) {
            knownHubs[index] = hub
        } else {
            knownHubs.append(hub)
        }
    }

    private func saveKnownHubs() {
        guard let data = try? JSONEncoder().encode(knownHubs) else { return }
        UserDefaults.standard.set(data, forKey: knownHubsKey)
    }

    private func saveCatalog() {
        guard let data = try? JSONEncoder().encode(catalog) else { return }
        UserDefaults.standard.set(data, forKey: catalogKey)
    }

    private static func loadCatalog(key: String) -> ProgrammingCatalog? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(ProgrammingCatalog.self, from: data)
    }

    private static func loadKnownHubs(key: String) -> [KnownHub] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let hubs = try? JSONDecoder().decode([KnownHub].self, from: data)
        else {
            return []
        }
        return hubs
    }
}
