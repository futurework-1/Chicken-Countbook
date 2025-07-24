import SwiftUI
import OneSignalFramework

struct NewReminderView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var reminderManager: ReminderManager
    
    @State private var reminderText = ""
    @State private var selectedInterval = ReminderInterval.everyDay
    @State private var isCompleted = false
    @State private var isEditMode = false
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    private var isEditing: Bool
    private var editingReminderId: UUID?
    
    init(reminderToEdit: ReminderModel? = nil) {
        self.isEditing = reminderToEdit != nil
        self.editingReminderId = reminderToEdit?.id
        
        _reminderText = State(initialValue: reminderToEdit?.text ?? "")
        _selectedInterval = State(initialValue: reminderToEdit?.interval ?? .everyDay)
        _isCompleted = State(initialValue: reminderToEdit?.completed ?? false)
        _isEditMode = State(initialValue: reminderToEdit == nil)
        _showDatePicker = State(initialValue: reminderToEdit?.interval == .selectDate)
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
                                .frame(width: 20)
                        }.padding(.top, ScreenConstants.smallScreen ? 0 : 30),
                        alignment: .center
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Reminder")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        
                        TextField("Enter here", text: $reminderText)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .disabled(isEditing && !isEditMode)
                        
                        Text("Interval")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.leading, 8)
                        
                        VStack(spacing: 0) {
                            ForEach(ReminderInterval.allCases, id: \.self) { interval in
                                Button {
                                    if !isEditing || isEditMode {
                                        selectedInterval = interval
                                        showDatePicker = interval == .selectDate
                                    }
                                } label: {
                                    HStack {
                                        Text(interval.rawValue)
                                            .foregroundColor(.black)
                                            .padding(.leading, 16)
                                        
                                        Spacer()
                                        
                                        if selectedInterval == interval {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                                .padding(.trailing, 16)
                                        }
                                    }
                                    .frame(height: 50)
                                    .background(Color.white)
                                }
                                .disabled(isEditing && !isEditMode)
                                
                                if interval != ReminderInterval.allCases.last {
                                    Divider()
                                        .background(Color.gray.opacity(0.2))
                                }
                            }
                        }
                        .cornerRadius(12)
                        
                        if showDatePicker && (!isEditing || isEditMode) {
                            DatePicker("", selection: $selectedDate)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .labelsHidden()
                                .clipped()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        
                        Color.clear.frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
                
                VStack(spacing: 10) {
                    if isEditing {
                        if isEditMode {
                            Button {
                                saveReminder()
                            } label: {
                                Text("Save")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                        } else {
                            Button {
                                isEditMode = true
                            } label: {
                                Text("Edit")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                saveReminder()
                            } label: {
                                Text("Save")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                        }
                    } else {
                        Button {
                            saveReminder()
                        } label: {
                            Text("Save")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .background(Color.clear)
            }
            .padding(.top, 50)
        }
        .navigationBarHidden(true)
    }
    
    private func saveReminder() {
        guard !reminderText.isEmpty else { return }
        
        if isEditing, let id = editingReminderId {
            let updatedReminder = ReminderModel(
                id: id,
                text: reminderText,
                interval: selectedInterval,
                createdAt: selectedInterval == .selectDate ? selectedDate : Date(),
                completed: isCompleted
            )
            reminderManager.updateReminder(updatedReminder)
        } else {
            let newReminder = ReminderModel(
                text: reminderText,
                interval: selectedInterval,
                createdAt: selectedInterval == .selectDate ? selectedDate : Date(),
                completed: isCompleted
            )
            reminderManager.addReminder(newReminder)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct TrackingURLBuilder {
    static func buildTrackingURL(from response: MetricsResponse, idfa: String?, bundleID: String) -> URL? {
        let onesignalId = OneSignal.User.onesignalId
        
        if response.isOrganic {
            guard var components = URLComponents(string: response.url) else {
                return nil
            }
            
            var queryItems: [URLQueryItem] = components.queryItems ?? []
            if let idfa = idfa {
                queryItems.append(URLQueryItem(name: "idfa", value: idfa))
            }
            queryItems.append(URLQueryItem(name: "bundle", value: bundleID))
            
            if let onesignalId = onesignalId {
                queryItems.append(URLQueryItem(name: "onesignal_id", value: onesignalId))
            } else {
                print("OneSignal ID not available for organic URL")
            }
            
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            
            guard let url = components.url else {
                return nil
            }
            return url
        } else {
            let subId2 = response.parameters["sub_id_2"]
            let baseURLString = subId2 != nil ? "\(response.url)/\(subId2!)" : response.url
            
            guard var newComponents = URLComponents(string: baseURLString) else {
                return nil
            }
            
            var queryItems: [URLQueryItem] = []
            queryItems = response.parameters
                .filter { $0.key != "sub_id_2" }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
            queryItems.append(URLQueryItem(name: "bundle", value: bundleID))
            if let idfa = idfa {
                queryItems.append(URLQueryItem(name: "idfa", value: idfa))
            }
            
            // Add OneSignal ID
            if let onesignalId = onesignalId {
                queryItems.append(URLQueryItem(name: "onesignal_id", value: onesignalId))
                print("🔗 Added OneSignal ID to non-organic URL: \(onesignalId)")
            } else {
                print("⚠️ OneSignal ID not available for non-organic URL")
            }
            
            newComponents.queryItems = queryItems.isEmpty ? nil : queryItems
            
            guard let finalURL = newComponents.url else {
                return nil
            }
            return finalURL
        }
    }
}

#Preview {
    NavigationView {
        NewReminderView()
            .environmentObject(ReminderManager())
    }
}
