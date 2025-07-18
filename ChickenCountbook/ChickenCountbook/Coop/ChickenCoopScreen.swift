import SwiftUI

struct ChickenCoopScreen: View {
    @EnvironmentObject private var chickenManager: ChickenManager
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            VStack {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 50 : 100)
                    .overlay(
                        Text("The chicken coop")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.top)
                        , alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            VStack {
                ScrollView {
                    if chickenManager.chickens.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "bird")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                            
                            Text("No chickens yet")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                            
                            Text("Add your first chicken to start")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(chickenManager.chickens) { chicken in
                                ChickenCardView(chicken: chicken)
                            }
                        }
                        .padding()
                    }
                }
                
                NavigationLink {
                    NewChickenScreen()
                } label: {
                    Text("Add new chicken")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
            }
            .padding(.top, 50)
            .padding(.bottom, 90)
        }
    }
}

struct ChickenCardView: View {
    let chicken: ChickenModel
    
    var body: some View {
        VStack {
            Image(chicken.imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.yellowLigthCustom, lineWidth: 2)
                )
                .overlay(
                    Text(chicken.name)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white).padding(.bottom, 5), alignment: .bottom
                )
          
        }
        .padding(8)
    }
}

#Preview {
    ChickenCoopScreen()
        .environmentObject(ChickenManager())
}
