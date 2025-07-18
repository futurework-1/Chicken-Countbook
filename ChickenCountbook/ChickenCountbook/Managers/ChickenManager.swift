import Foundation

class ChickenManager: ObservableObject {
    @Published var chickens: [ChickenModel] = []
    private let key = "chickens"
    
    init() {
        load()
    }
    
    func addChicken(_ chicken: ChickenModel) {
        chickens.append(chicken)
        save()
    }
    
    func updateChicken(_ chicken: ChickenModel) {
        if let index = chickens.firstIndex(where: { $0.id == chicken.id }) {
            chickens[index] = chicken
            save()
        }
    }
    
    func deleteChicken(id: UUID) {
        chickens.removeAll { $0.id == id }
        save()
    }
    
    func clearAllData() {
        chickens.removeAll()
        save()
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(chickens) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode([ChickenModel].self, from: data) {
            chickens = saved
        }
    }
} 