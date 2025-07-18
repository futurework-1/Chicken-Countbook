import Foundation

class ReminderManager: ObservableObject {
    @Published var reminders: [ReminderModel] = []
    private let key = "reminders"
    
    init() {
        load()
    }
    
    func addReminder(_ reminder: ReminderModel) {
        reminders.append(reminder)
        save()
    }
    
    func updateReminder(_ reminder: ReminderModel) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            save()
        }
    }
    
    func deleteReminder(id: UUID) {
        reminders.removeAll { $0.id == id }
        save()
    }
    
    func clearAllReminders() {
        reminders.removeAll()
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([ReminderModel].self, from: data) {
            reminders = saved
        }
    }
} 