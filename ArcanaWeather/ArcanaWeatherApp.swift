import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency

@main
struct ArcanaWeatherApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        ATTrackingManager.requestTrackingAuthorization { _ in }
                    }
                }
        }
    }
}
