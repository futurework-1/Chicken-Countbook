import SwiftUI
import FirebaseCore
import OneSignalFramework

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white)
            )
            .frame(height: 64)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var lastPermissionCheck: Date?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize(AppConstants.oneSignalAppID, withLaunchOptions: launchOptions)
        
        UNUserNotificationCenter.current().delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackingAction),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        return true
    }
    
    @objc private func handleTrackingAction() {
        if UIApplication.shared.applicationState == .active {
            let now = Date()
            if let last = lastPermissionCheck, now.timeIntervalSince(last) < 2 {
                return
            }
            lastPermissionCheck = now
            NotificationCenter.default.post(name: .checkTrackingPermission, object: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

struct NewChickenScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var chickenManager: ChickenManager
    @State private var name: String = ""
    @State private var breed: String = ""
    @State private var arrivalDate: String = ""
    @State private var notes: String = ""
    @State private var layingRate: String = ""
    @State private var status: ChickenStatus = .active
    @State private var comment: String = ""
    let chickenPlaceholders: [ImageResource] = [.chicken1, .chicken2, .chicken3, .chicken4, .chicken5, .chicken6]
    @State private var selectedPlaceholder: ImageResource
    
    init() {
        _selectedPlaceholder = State(initialValue: .chicken1)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && 
        !breed.isEmpty && 
        !layingRate.isEmpty &&
        Int(layingRate.trimmingCharacters(in: .whitespaces)) != nil
    }
    
    private func imageNameFor(_ resource: ImageResource) -> String {
        switch resource {
        case .chicken1: return "chicken1"
        case .chicken2: return "chicken2"
        case .chicken3: return "chicken3"
        case .chicken4: return "chicken4"
        case .chicken5: return "chicken5"
        case .chicken6: return "chicken6"
        default: return "chicken1"
        }
    }
    
    private func randomizeImage() {
        selectedPlaceholder = chickenPlaceholders.randomElement() ?? .chicken1
    }
    
    private func saveChicken() {
        guard !name.isEmpty else {
            return
        }
        
        guard !breed.isEmpty else {
            return
        }
        
        let trimmedLayingRate = layingRate.trimmingCharacters(in: .whitespaces)
        guard let layingRateInt = Int(trimmedLayingRate) else {
            return
        }
        
        let imageName = imageNameFor(selectedPlaceholder)
        
        let chicken = ChickenModel(
            name: name,
            breed: breed,
            arrivalDate: Date(),
            notes: notes,
            layingRate: layingRateInt,
            status: status,
            comment: comment,
            imageName: imageName
        )
        
        chickenManager.addChicken(chicken)
        dismiss()
    }
    
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
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                            
                            Text("The chicken coop")
                                .font(.system(size: 17, weight: .medium))
                                .padding(.top)
                            
                            Image(systemName: "chevron.left")
                                .foregroundColor(.clear)
                                .font(.system(size: 22, weight: .medium))
                            Spacer()
                        }.padding(.top, ScreenConstants.smallScreen ? 0 : 30),
                        alignment: .center
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Image(selectedPlaceholder)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 204, height: 201)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .foregroundColor(.white)
                            TextField("Enter here", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Breed")
                                .foregroundColor(.white)
                            TextField("Enter here", text: $breed)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Arrival date")
                                .foregroundColor(.white)
                            TextField("Enter here", text: $arrivalDate)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .foregroundColor(.white)
                            TextField("Enter here", text: $notes)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Laying rate")
                                .foregroundColor(.white)
                            TextField("Enter here", text: $layingRate)
                                .textFieldStyle(CustomTextFieldStyle())
                                .keyboardType(.numberPad)
                                .onChange(of: layingRate) { newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue {
                                        layingRate = filtered
                                    }
                                }
                                .onChange(of: layingRate) { newValue in
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue {
                                        layingRate = filtered
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .foregroundColor(.white)
                            VStack {
                                HStack(spacing: 16) {
                                    StatusButton(icon: "active", isSelected: status == .active) {
                                        status = .active
                                    }
                                    StatusButton(icon: "notLaying", isSelected: status == .notLaying) {
                                        status = .notLaying
                                    }
                                }
                                HStack(spacing: 16) {
                                    StatusButton(icon: "sold", isSelected: status == .sold) {
                                        status = .sold
                                    }
                                    StatusButton(icon: "deceased", isSelected: status == .deceased) {
                                        status = .deceased
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comment")
                                .foregroundColor(.white)
                            TextField("Enter here", text: $comment)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        Button(action: saveChicken) {
                            Text("Save")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.blue : Color.gray)
                                .cornerRadius(14)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 16)
                        
                        NavigationLink {
                            ChickenProductivityScreen()
                        } label: {
                            HStack {
                                Image(.statNavIcon)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .padding(5)
                                Text("Chicken Productivity")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
                .padding(.bottom, 30)
            }
            .padding(.top, 50)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            randomizeImage()
        }
    }
}

struct StatusButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(isSelected ? (icon + "S") : icon)
                .resizable()
                .scaledToFit()
                .frame(width: 165, height: 70)
        }
    }
}

#Preview {
    NewChickenScreen()
        .environmentObject(ChickenManager())
}
