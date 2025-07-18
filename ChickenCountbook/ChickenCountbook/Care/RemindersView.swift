import SwiftUI

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

#Preview {
    NavigationView {
        RemindersView()
            .environmentObject(ReminderManager())
    }
}
