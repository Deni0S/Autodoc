import SwiftUI

@main
struct AppScene: App {

    // MARK: - Properties

    private(set) static var coordinator = AppAssembly().build()
    @UIApplicationDelegateAdaptor(AppDelegates.self) private var appDelegate
    @State private var rootViewController: UIViewController?

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ZStack {
                    if let rootViewController = rootViewController {
                        ViewControllerRepresentable(rootViewController)
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                }
            }
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
            .task {
                 rootViewController = await AppScene.coordinator.managers.routing.rootViewController
            }
        }
    }
}
