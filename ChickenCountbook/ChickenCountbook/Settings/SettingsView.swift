import SwiftUI
import WebKit

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("unitType") private var unitType = UnitType.dozens
    
    enum UnitType: String, CaseIterable {
        case dozens, pieces
    }
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Color.yellowLigthCustom
                    .frame(height: ScreenConstants.smallScreen ? 60 : 100)
                    .overlay(
                        Text("Settings")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.bottom)
                        , alignment: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
            VStack {
                ScrollView {
                    VStack(spacing: 12) {
                        settingsCard {
                            HStack {
                                Text("Notifications")
                                    .font(.system(size: 15, weight: .regular))
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .tint(.green)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical)
                        }
                        
                        settingsCard {
                            HStack {
                                Text("Units")
                                    .font(.system(size: 15, weight: .regular))
                                Spacer()
                                HStack(spacing: 8) {
                                    ForEach(UnitType.allCases, id: \.self) { unit in
                                        Button(action: {
                                            unitType = unit
                                        }) {
                                            Text(unit.rawValue)
                                                .font(.system(size: 15, weight: .regular))
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    Capsule()
                                                        .fill(unitType == unit ? Color.yellow.opacity(0.7) : Color.gray.opacity(0.2))
                                                )
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        
                        navigationSettingsCard(title: "Data") {
                            DataView()
                        }
                        
                        navigationSettingsCard(title: "Privacy & Security") {
                            WebViewPage(title: "Privacy Policy", url: URL(string: "https://sites.google.com/view/chickencountbook/privacy-policy")!)
                        }
                        
                        navigationSettingsCard(title: "Developer Info") {
                            WebViewPage(title: "About the Developer", url: URL(string: "https://sites.google.com/view/chickencountbook/app-support")!)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.top, 50)
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
    }
    
    @ViewBuilder
    private func navigationSettingsCard<Destination: View>(title: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
        )
    }
}



#Preview {
    SettingsView()
}


struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct WebViewPage: View {
    @Environment(\.presentationMode) var presentationMode
    let title: String
    let url: URL
    
    var body: some View {
        ZStack {
            Image(.mainBack)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.leading)
                    }
                    
                    Spacer()
                    
                    Text(title)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding()
                
                WebView(url: url)
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
            }
        }
        .navigationBarHidden(true)
    }
}
