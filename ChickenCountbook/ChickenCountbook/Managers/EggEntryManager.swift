import Foundation

class EggEntryManager: ObservableObject {
    @Published var entries: [EggEntryModel] = []
    @Published var notes: [String] = []
    private let key = "egg_entries"
    private let notesKey = "egg_notes"
    
    init() {
        load()
        loadNotes()
    }
    
    func addEntry(_ entry: EggEntryModel) {
        entries.append(entry)
        save()
    }
    
    func addNote(_ note: String) {
        notes.append(note)
        saveNotes()
    }
    
    func clearAllData() {
        entries.removeAll()
        notes.removeAll()
        save()
        saveNotes()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([EggEntryModel].self, from: data) {
            entries = saved
        }
    }
    
    private func saveNotes() {
        UserDefaults.standard.set(notes, forKey: notesKey)
    }
    
    private func loadNotes() {
        if let saved = UserDefaults.standard.stringArray(forKey: notesKey) {
            notes = saved
        }
    }
} 