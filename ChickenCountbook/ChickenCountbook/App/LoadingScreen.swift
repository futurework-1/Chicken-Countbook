import SwiftUI

struct LoadingScreen: View {
    @State private var isLoading = true
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    
    var body: some View {
        if isLoading {
            ZStack {
                Image(.mainBack)
                    .resizable()
                    .ignoresSafeArea()
                
                Image(.loadingTitle)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 30)
            }
            .onReceive(NotificationCenter.default.publisher(for: .splashTransition)) { _ in
                withAnimation {
                    self.isLoading = false
                }
            }

        } else if !hasSeenTutorial {
            OnboardingScreen()
        } else {
            MainScreen()
        }
    }
}

#Preview {
    LoadingScreen()
}
