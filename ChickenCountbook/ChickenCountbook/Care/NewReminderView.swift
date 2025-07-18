import SwiftUI

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

#Preview {
    NavigationView {
        NewReminderView()
            .environmentObject(ReminderManager())
    }
}
