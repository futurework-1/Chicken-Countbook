import SwiftUI

struct MainScreen: View {
    @State private var tabSelected: Tab = .statIcon
    @EnvironmentObject private var chickenManager: ChickenManager
    @EnvironmentObject private var eggManager: EggEntryManager

    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TabView(selection: $tabSelected) {
                        ProductivityScreen()
                            .environmentObject(eggManager)
                            .tag(Tab.statIcon)
                        
                        ChickenCoopScreen()
                            .environmentObject(chickenManager)
                            .tag(Tab.birdIcon)
                        
                        CareScreen()
                            .tag(Tab.calendarIcon)
                        
                        SettingsView()
                            .tag(Tab.settingsIcon)
                    }
                }
                VStack {
                    Spacer()
                    CustomTabBar(selectedTab: $tabSelected)
                }
            }
        }
    }
}


#Preview {
    MainScreen()
        .environmentObject(EggEntryManager())
        .environmentObject(ChickenManager())
        .environmentObject(ReminderManager())
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Image(tab.rawValue)
                        .renderingMode(.template)
                        .foregroundColor(tab == selectedTab ? .redCustom : .orangeCustom)
                        .padding(.horizontal, 13)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    
                }
            }
            .frame(height: 58)
            .padding(.horizontal, 10)
            .background(.yellowLigthCustom)
            .cornerRadius(40)
            .padding()
        }
    }
}

enum Tab: String, CaseIterable {
    case statIcon
    case birdIcon
    case calendarIcon
    case settingsIcon
}
