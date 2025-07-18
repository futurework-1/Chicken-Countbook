import Foundation

struct ReminderModel: Identifiable, Codable {
    let id: UUID
    let text: String
    let interval: ReminderInterval
    let createdAt: Date
    var completed: Bool
    
    init(id: UUID = UUID(), text: String, interval: ReminderInterval, createdAt: Date = Date(), completed: Bool = false) {
        self.id = id
        self.text = text
        self.interval = interval
        self.createdAt = createdAt
        self.completed = completed
    }
}

enum ReminderInterval: String, Codable, CaseIterable {
    case everyHour = "Every hour"
    case everyDay = "Every day"
    case every3Days = "Every 3 days"
    case selectDate = "Select date"
    
    var seconds: TimeInterval {
        switch self {
        case .everyHour:
            return 3600
        case .everyDay:
            return 86400
        case .every3Days:
            return 259200
        case .selectDate:
            return 0 
        }
    }
} 
