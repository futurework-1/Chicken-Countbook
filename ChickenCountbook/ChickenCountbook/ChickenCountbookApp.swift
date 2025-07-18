import SwiftUI

@main
struct ChickenCountbookApp: App {
    @StateObject private var eggManager = EggEntryManager()
    @StateObject private var chickenManager = ChickenManager()
    @StateObject private var reminderManager = ReminderManager()
    
    var body: some Scene {
        WindowGroup {
            LoadingScreen()
                .environmentObject(eggManager)
                .environmentObject(chickenManager)
                .environmentObject(reminderManager)
        }
    }
}
