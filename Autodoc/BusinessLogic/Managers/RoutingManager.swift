import UIKit

// MARK: - Interfaces

protocol RoutingInterface {
    var rootViewController: UINavigationController { get }
}

// MARK: - Manager

final actor RoutingManager: RoutingInterface {

    // MARK: - Properties

    let rootViewController: UINavigationController

    // MARK: - Initial

    init(
        rootViewController: UINavigationController
    ) {
        self.rootViewController = rootViewController
    }
}
