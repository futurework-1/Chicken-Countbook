import SwiftUI
import WebKit
import FirebaseCore
import OneSignalFramework

struct ChickenProductivityScreen: View {
    enum PeriodType: String, CaseIterable, Identifiable { case weeks = "Weeks", months = "Months"; var id: String { rawValue } }
    
    @EnvironmentObject var manager: ChickenManager
    @Environment(\.dismiss) private var dismiss
    @State private var period: PeriodType = .weeks
    @State private var currentWeek: Int = 12
    @State private var currentMonth: Date = Date()
    @State private var barValues: [Int] = StatsScreen.randomData(count: 7)
    @State private var selectedLabelIndex: Int? = nil
    
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
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 22, weight: .medium))
                            }
                            .padding(.top)
                            .padding(.leading)
                            
                            Spacer()
                            
                            Text("Chicken productivity")
                                .font(.system(size: 17, weight: .medium))
                                .padding(.top)
                            
                            Image(systemName: "chevron.left")
                                .foregroundColor(.clear)
                                .font(.system(size: 22, weight: .medium))
                            Spacer()
                        }.padding(.top, ScreenConstants.smallScreen ? 0 : 30),
                        alignment: .center
                    )
                    .ignoresSafeArea(edges: .top)
                Spacer()
            }
                VStack(spacing: 10) {
                    CustomSegmentedControl(
                        items: PeriodType.allCases,
                        selection: Binding(get: { period }, set: { setPeriod($0) })
                    )
                    .frame(height: 40)
                    .padding(.horizontal)
                    if !manager.chickens.isEmpty {
                        ScrollView {
                            HStack {
                                Text(period == .weeks ? "Week \(currentWeek)" : monthYearString(for: currentMonth))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { prevPeriod() }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 22, weight: .bold))
                                }
                                Button(action: { nextPeriod() }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 22, weight: .bold))
                                }
                                .padding(.leading)
                            }
                            .padding()
                            Image(period == .weeks ? .chartBack : .chartBackM)
                                .resizable()
                                .frame(width: 350, height: 390)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        VStack {
                                            HStack(alignment: .bottom, spacing: period == .weeks ? 16 : 25) {
                                                ForEach(0..<(period == .weeks ? 7 : 5), id: \ .self) { idx in
                                                    let value = barValues[safe: idx] ?? 10
                                                    BarView(value: value, maxValue: 60)
                                                        .frame(width: 24)
                                                }
                                            }
                                            .frame(height: 220)
                                            .padding(.horizontal, 30)
                                            HStack(spacing: period == .weeks ? 5 : 16) {
                                                ForEach(0..<(period == .weeks ? 7 : 5), id: \ .self) { idx in
                                                    Button(action: {
                                                        selectedLabelIndex = idx
                                                        barValues = StatsScreen.randomData(count: period == .weeks ? 7 : 5)
                                                    }) {
                                                        Text(period == .weeks ? weekDays[idx] : weekLabels[idx])
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(selectedLabelIndex == idx ? .white : .blue)
                                                            .frame(width: 38, height: 32)
                                                            .background(selectedLabelIndex == idx ? Color.blue : Color.white)
                                                            .clipShape(Capsule())
                                                            .overlay(
                                                                Capsule().stroke(Color.blue, lineWidth: 2)
                                                            )
                                                    }
                                                }
                                            }
                                            .padding(.top, 20)
                                            .padding(.horizontal, 30)
                                        }
                                        
                                    }
                                        .offset(y: -22)
                                        .offset(x: period == .weeks ? 15 : 6)
                                )
                            
                        }
                        .padding(.bottom, 30)
                    } else {
                        Spacer().frame(height: 60)
                        Text("No data yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        Spacer()
                    }
                }
                .padding(.top, 50)
        }
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Actions
    private func setPeriod(_ newPeriod: PeriodType) {
        if period != newPeriod {
            period = newPeriod
            barValues = StatsScreen.randomData(count: newPeriod == .weeks ? 7 : 5)
        }
    }
    
    private func prevPeriod() {
        if period == .weeks {
            currentWeek = max(1, currentWeek - 1)
            barValues = StatsScreen.randomData(count: 7)
        } else {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
            barValues = StatsScreen.randomData(count: 5)
        }
    }
    private func nextPeriod() {
        if period == .weeks {
            currentWeek += 1
            barValues = StatsScreen.randomData(count: 7)
        } else {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
            barValues = StatsScreen.randomData(count: 5)
        }
    }
    
    // MARK: - Helpers
    private var weekDays: [String] { ["M", "T", "W", "T", "F", "S", "S"] }
    private var weekLabels: [String] { ["W1", "W2", "W3", "W4", "W5"] }
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
    static func randomData(count: Int) -> [Int] {
        (0..<count).map { _ in Int.random(in: 10...60) }
    }
}

struct PrivacyView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let ref: URL
    private let webView: WKWebView
    
    init(ref: URL) {
        self.ref = ref
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences = WKPreferences()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView = WKWebView(frame: .zero, configuration: configuration)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: ref))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: PrivacyView
        private var popupWebView: OverlayPrivacyWindowController?
        
        init(_ parent: PrivacyView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            configuration.websiteDataStore = WKWebsiteDataStore.default()
            let newOverlay = WKWebView(frame: parent.webView.bounds, configuration: configuration)
            newOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            newOverlay.navigationDelegate = self
            newOverlay.uiDelegate = self
            webView.addSubview(newOverlay)
            
            let viewController = OverlayPrivacyWindowController()
            viewController.overlayView = newOverlay
            popupWebView = viewController
            UIApplication.topMostController()?.present(viewController, animated: true)
            
            return newOverlay
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            popupWebView?.dismiss(animated: true)
        }
    }
}

#Preview {
    ChickenProductivityScreen().environmentObject(ChickenManager())
}
