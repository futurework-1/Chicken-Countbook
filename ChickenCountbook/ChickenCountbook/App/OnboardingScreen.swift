import SwiftUI

struct OnboardingScreen: View {
    @State private var selection = 0
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            TabView(selection: $selection) {
                OnboardingPageView(
                    title: .onbTitle1,
                    headline: "Keep Count,\nStay Organized",
                    description: "Easily log how many eggs your chickens lay each day. View weekly and monthly stats to see trends and stay on top of your flock's productivity.",
                    buttonTitle: "Continue",
                    buttonAction: { selection = 1 }
                )
                .tag(0)
                
                OnboardingPageView(
                    title: .onbTitle2,
                    headline: "Know Every\nChicken",
                    description: "Add individual profiles for your hens — track their breed, age, and laying habits. See who's laying best and get alerts if something's off.",
                    buttonTitle: "Continue",
                    buttonAction: { selection = 2 }
                )
                .tag(1)
                
                OnboardingPageView(
                    title: .onbTitle3,
                    headline: "Never Miss a\nTask",
                    description: "Set custom reminders for egg collection, feeding, cleaning, or vet care. Your personal poultry planner keeps your hens happy and healthy.",
                    buttonTitle: "Get started",
                    buttonAction: { hasSeenTutorial = true }
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

struct OnboardingPageView: View {
    let title: ImageResource
    let headline: String
    let description: String
    let buttonTitle: String
    let buttonAction: () -> Void
    
    var body: some View {
        VStack {
            Image(title)
                .resizable()
                .scaledToFit()
                .padding(30)
            
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .frame(width: 350, height: 370)
                VStack {
                    Text(headline)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundColor(.blueCustom)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Text(description)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.blueCustom)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(width: 300, height: 350)
            }
            Spacer()
            Button(action: buttonAction) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 70)
        }
    }
}

#Preview {
    OnboardingScreen()
}
