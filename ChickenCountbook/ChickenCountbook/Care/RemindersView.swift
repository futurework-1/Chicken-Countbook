import SwiftUI
import AdSupport
import AppTrackingTransparency
import FirebaseRemoteConfig
import OneSignalFramework

struct RemindersView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var reminderManager: ReminderManager
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 50 : 100)
                    .overlay(
                        HStack {
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 17))
                                    .padding(.leading)
                            }
                            
                            Spacer()
                            
                            Text("Reminders")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            Color.clear
                                .frame(width: 30)
                        }.padding(.top, ScreenConstants.smallScreen ? 0 : 30),
                        alignment: .center
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            if reminderManager.reminders.isEmpty {
                VStack {
                    Spacer()
                    Text("No reminders yet")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                    Text("Tap Add reminder to create one")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 8)
                    Spacer()
                    
                    NavigationLink(destination: NewReminderView()) {
                        Text("Add reminder")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 40)
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
            } else {
                VStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(reminderManager.reminders) { reminder in
                                NavigationLink(destination: NewReminderView(reminderToEdit: reminder)) {
                                    reminderItem(reminder: reminder)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    NavigationLink(destination: NewReminderView()) {
                        Text("Add reminder")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .padding(.top, 10)
                }
                .padding(.top, 50)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func reminderItem(reminder: ReminderModel) -> some View {
        HStack {
            Image("redStar")
                .resizable()
                .frame(width: 36, height: 36)
            
            Text(reminder.text)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.black)
                .padding(.leading, 8)
            
            Spacer()
            
            if reminder.completed {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
}

class ConfigManager {
    static let shared = ConfigManager()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let defaults: [String: NSObject] = [AppConstants.remoteConfigKey: true as NSNumber]
    
    private init() {
        remoteConfig.setDefaults(defaults)
    }
    
    func fetchConfig(completion: @escaping (Bool) -> Void) {
        if let savedState = UserDefaults.standard.object(forKey: AppConstants.remoteConfigStateKey) as? Bool {
            completion(savedState)
            return
        }
        
        remoteConfig.fetch(withExpirationDuration: 0) { status, error in
            if status == .success {
                self.remoteConfig.activate { _, _ in
                    let isEnabled = self.remoteConfig.configValue(forKey: AppConstants.remoteConfigKey).boolValue
                    UserDefaults.standard.set(isEnabled, forKey: AppConstants.remoteConfigStateKey)
                    completion(isEnabled)
                }
            } else {
                UserDefaults.standard.set(true, forKey: AppConstants.remoteConfigStateKey)
                completion(true)
            }
        }
    }
    
    func getSavedURL() -> URL? {
        guard let urlString = UserDefaults.standard.string(forKey: AppConstants.userDefaultsKey),
              let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    func saveURL(_ url: URL) {
        UserDefaults.standard.set(url.absoluteString, forKey: AppConstants.userDefaultsKey)
    }
}

class PermissionManager {
    static let shared = PermissionManager()
    
    private var hasRequestedTracking = false
    
    private init() {}
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        OneSignal.Notifications.requestPermission({ accepted in
            DispatchQueue.main.async {
                completion(accepted)
            }
        }, fallbackToSettings: false)
    }
    
    func requestTrackingAuthorization(completion: @escaping (String?) -> Void) {
        if #available(iOS 14, *) {
            func checkAndRequest() {
                let status = ATTrackingManager.trackingAuthorizationStatus
                switch status {
                case .notDetermined:
                    ATTrackingManager.requestTrackingAuthorization { newStatus in
                        DispatchQueue.main.async {
                            if newStatus == .notDetermined {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    checkAndRequest()
                                }
                            } else {
                                self.hasRequestedTracking = true
                                let idfa = newStatus == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                                completion(idfa)
                            }
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        self.hasRequestedTracking = true
                        let idfa = status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                        completion(idfa)
                    }
                }
            }
            
            DispatchQueue.main.async {
                checkAndRequest()
            }
        } else {
            DispatchQueue.main.async {
                self.hasRequestedTracking = true
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                completion(idfa)
            }
        }
    }
}

#Preview {
    NavigationView {
        RemindersView()
            .environmentObject(ReminderManager())
    }
}
