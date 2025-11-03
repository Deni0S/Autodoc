import SwiftUI

// MARK: - AppDelegates

final class AppDelegates: NSObject, ObservableObject {

    private let lifecycleDelegate: AppLifecycleInterface = AppScene.coordinator
}

// MARK: - ApplicationDelegate

extension AppDelegates: UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        lifecycleDelegate.handleEventsForBackgroundURLSession(
            for: identifier,
            completionHandler: completionHandler)
    }
}
