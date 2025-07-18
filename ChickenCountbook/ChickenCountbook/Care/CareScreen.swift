import SwiftUI

struct CareScreen: View {
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 50 : 100)
                    .overlay(
                        Text("Reminders and care calendar")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.top, ScreenConstants.smallScreen ? 0 : 30),
                        alignment: .center
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            
            VStack(spacing: 16) {
                navigationCard(title: "Reminders", icon: "blueStar", iconColor: .blue) {
                    RemindersView()
                }
                
                navigationCard(title: "Care Calendar", icon: "blueStar", iconColor: .blue) {
                    CareCalendar()
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 50)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func navigationCard<Destination: View>(title: String, icon: String, iconColor: Color, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(destination: destination()) {
            HStack {
                Image(icon)
                    .resizable()
                    .frame(width: 36, height: 36)
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
}

#Preview {
    CareScreen()
}
