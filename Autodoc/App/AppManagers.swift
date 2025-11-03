// MARK: - Interfaces

protocol AppManagersInterface {
    var cache: CacheInterface { get async }
    var logger: LoggerInterface { get async }
    var network: NetworkInterface { get async }
    var routing: RoutingInterface { get async }
}

// MARK: - Managers

struct AppManagers: AppManagersInterface {
    let cache: CacheInterface
    let logger: LoggerInterface
    let network: NetworkInterface
    let routing: RoutingInterface
}
