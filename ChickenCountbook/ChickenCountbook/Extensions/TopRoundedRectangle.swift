import SwiftUI
import CryptoKit
import WebKit

struct TopRoundedRectangle: Shape {
    var radius: CGFloat = 20
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
} 


class OverlayPrivacyWindowController: UIViewController {
    var overlayView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

enum CryptoUtils {
    static func md5Hex(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

extension UIApplication {
    static var keyWindow: UIWindow {
        shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last!
    }
    
    class func topMostController(controller: UIViewController? = keyWindow.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topMostController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topMostController(controller: selected)
        }
        if let presented = controller?.presentedViewController {
            return topMostController(controller: presented)
        }
        return controller
    }
}

extension Notification.Name {
    static let didFetchTrackingURL = Notification.Name("didFetchTrackingURL")
    static let checkTrackingPermission = Notification.Name("checkTrackingPermission")
    static let notificationPermissionResolved = Notification.Name("notificationPermissionResolved")
    static let splashTransition = Notification.Name("splashTransition")
}

