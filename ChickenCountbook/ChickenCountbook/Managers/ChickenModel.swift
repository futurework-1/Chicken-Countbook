import Foundation

struct ChickenModel: Identifiable, Codable {
    let id: UUID
    let name: String
    let breed: String
    let arrivalDate: Date
    let notes: String
    let layingRate: Int
    let status: ChickenStatus
    let comment: String
    let imageName: String
    
    init(name: String, breed: String, arrivalDate: Date, notes: String, layingRate: Int, status: ChickenStatus, comment: String, imageName: String) {
        self.id = UUID()
        self.name = name
        self.breed = breed
        self.arrivalDate = arrivalDate
        self.notes = notes
        self.layingRate = layingRate
        self.status = status
        self.comment = comment
        self.imageName = imageName
    }
}

enum ChickenStatus: String, Codable {
    case active = "Active"
    case notLaying = "Not laying"
    case sold = "Sold"
    case deceased = "Deceased"
} 