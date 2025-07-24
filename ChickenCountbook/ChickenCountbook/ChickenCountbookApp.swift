import SwiftUI

@main
struct ChickenCountbookApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var eggManager = EggEntryManager()
    @StateObject private var chickenManager = ChickenManager()
    @StateObject private var reminderManager = ReminderManager()
    
    var body: some Scene {
        WindowGroup {
            BlackWindow(rootView:                         LoadingScreen()
                .environmentObject(eggManager)
                .environmentObject(chickenManager)
                .environmentObject(reminderManager), remoteConfigKey: AppConstants.remoteConfigKey)
        }
    }
}
