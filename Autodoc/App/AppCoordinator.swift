import Foundation

// MARK: - Interfaces

protocol AppCoordinatorInterface: AppLifecycleInterface {
    var managers: AppManagersInterface { get async }
}

protocol AppLifecycleInterface {
    func handleEventsForBackgroundURLSession(for identifier: String, completionHandler: @escaping () -> Void)
}

// MARK: - Coordinator

final actor AppCoordinator: AppCoordinatorInterface {

    // MARK: - Properties

    let managers: AppManagersInterface

    // MARK: - Initial

    init(
        managers: AppManagersInterface
    ) {
        self.managers = managers
    }
}

// MARK: - AppLifecycleInterface

extension AppCoordinator: @preconcurrency AppLifecycleInterface {

    func handleEventsForBackgroundURLSession(
        for identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        Task {
            let networkManager = await managers.network
            await networkManager.backgroundService.setupDelegate(
                for: identifier, completionHandler: completionHandler)
        }
    }
}
