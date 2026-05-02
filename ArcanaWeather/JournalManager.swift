import Foundation

class JournalManager: ObservableObject {
    @Published private(set) var entries: [JournalEntry] = []
    private let storageKey = "arcana_journal_entries"

    struct JournalEntry: Codable, Identifiable {
        var id: String { dateKey }
        let dateKey: String
        var text: String
        var card: String
        var condition: String
        let createdAt: Date
        var updatedAt: Date
    }

    init() { load() }

    var todayKey: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: Date())
    }

    func todayEntry() -> JournalEntry? {
        entries.first { $0.dateKey == todayKey }
    }

    func getText(for dateKey: String) -> String {
        entries.first { $0.dateKey == dateKey }?.text ?? ""
    }

    func save(text: String, card: String, condition: String) {
        let key = todayKey
        if let idx = entries.firstIndex(where: { $0.dateKey == key }) {
            entries[idx].text = text
            entries[idx].card = card
            entries[idx].condition = condition
            entries[idx].updatedAt = Date()
        } else {
            let entry = JournalEntry(
                dateKey: key, text: text, card: card,
                condition: condition, createdAt: Date(), updatedAt: Date()
            )
            entries.insert(entry, at: 0)
        }
        // Keep last 90 days
        if entries.count > 90 {
            entries = Array(entries.prefix(90))
        }
        persist()
    }

    func deleteEntry(_ dateKey: String) {
        entries.removeAll { $0.dateKey == dateKey }
        persist()
    }

    var recentEntries: [JournalEntry] {
        entries.sorted { $0.dateKey > $1.dateKey }
    }

    func dateLabel(for key: String) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        guard let date = fmt.date(from: key) else { return key }
        let display = DateFormatter()
        display.locale = Locale(identifier: "ja_JP")
        display.dateFormat = "M月d日（E）"
        return display.string(from: date)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let list = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = list
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
