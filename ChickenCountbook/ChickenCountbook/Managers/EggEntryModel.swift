import Foundation

struct EggEntryModel: Identifiable, Codable {
    let id: UUID
    let date: Date
    let quantity: Int
    let chickenName: String?
    
    init(date: Date, quantity: Int, chickenName: String?) {
        self.id = UUID()
        self.date = date
        self.quantity = quantity
        self.chickenName = chickenName
    }
} 