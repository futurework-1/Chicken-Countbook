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

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchMetrics(bundleID: String, salt: String, idfa: String?, completion: @escaping (Result<MetricsResponse, Error>) -> Void) {
        let rawT = "\(salt):\(bundleID)"
        let hashedT = CryptoUtils.md5Hex(rawT)
        
        var components = URLComponents(string: AppConstants.metricsBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "b", value: bundleID),
            URLQueryItem(name: "t", value: hashedT)
        ]
        
        guard let url = components?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let isOrganic = json["is_organic"] as? Bool ?? false
                    guard let url = json["URL"] as? String else {
                        completion(.failure(NetworkError.invalidResponse))
                        return
                    }
                    
                    let parameters = json.filter { $0.key != "is_organic" && $0.key != "URL" }
                        .compactMapValues { $0 as? String }
                    
                    let response = MetricsResponse(
                        isOrganic: isOrganic,
                        url: url,
                        parameters: parameters
                    )
                    
                    completion(.success(response))
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
}


#Preview {
    CareScreen()
}
