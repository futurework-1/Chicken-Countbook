import SwiftUI

struct DataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteConfirmation = false
    @EnvironmentObject private var eggManager: EggEntryManager
    @EnvironmentObject private var chickenManager: ChickenManager
    @EnvironmentObject private var reminderManager: ReminderManager
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 60 : 100)
                    .overlay(
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.blue)
                                    .padding(.leading)
                            }
                            
                            Spacer()
                            
                            Text("Data")
                                .font(.system(size: 17, weight: .medium))
                            
                            Spacer()
                            
                            Color.clear
                                .frame(width: 10)
                                .padding(.trailing)
                        }.padding(.top, ScreenConstants.smallScreen ? 0 : 30),
                        alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            VStack(spacing: 16) {
                Button(action: {
                    showingDeleteConfirmation = true
                }) {
                    HStack {
                        Text("Notes and statistics history")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Clear")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .alert("You will delete history forever", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("Are you sure you want to delete your notes and statistics history?")
        }
    }
    
    private func clearAllData() {
        eggManager.clearAllData()
        chickenManager.clearAllData()
        reminderManager.clearAllReminders()
        
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
            UserDefaults.standard.synchronize()
        }
        
        UserDefaults.standard.set(false, forKey: "notificationsEnabled")
        UserDefaults.standard.set("dozens", forKey: "unitType")
    }
}

#Preview {
    NavigationView {
        DataView()
            .environmentObject(EggEntryManager())
            .environmentObject(ChickenManager())
            .environmentObject(ReminderManager())
    }
}
