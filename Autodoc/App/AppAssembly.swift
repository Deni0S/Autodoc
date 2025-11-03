import UIKit

struct AppAssembly {

    // MARK: - PublicMethods

    public func build() -> AppCoordinatorInterface {
        let managers = buildManagers()
        let coordinator = AppCoordinator(
            managers: managers)
        return coordinator
    }
}

// MARK: - PrivateMethods

private extension AppAssembly {

    func buildManagers() -> AppManagersInterface {
        let restService = buildRestService()
        let backgoundService = buildBackgroundService()
        let networkManager = buildNetworkManager(
            restService: restService,
            backgroundSession: backgoundService)
        let cacheManager = buildCacheManager()
        let rootController = buildRootController(
            restService: restService,
            backgoundService: backgoundService,
            cacheManager: cacheManager)
        let routingManager = buildRoutingManager(
            rootViewController: rootController)
        let loggerManager = buildLoggerManager()
        return AppManagers(
            cache: cacheManager,
            logger: loggerManager,
            network: networkManager,
            routing: routingManager)
    }

    func buildCacheManager() -> CacheInterface {
        let appleCacheImageService = AppleCacheImageServiceAssembly().build()
        let cacheManager = CacheManager(
            imageService: appleCacheImageService)
        return cacheManager
    }

    func buildRestService() -> RestInterface {
        let appleRestService = AppleRestServiceAssembly().build()
        return appleRestService
    }

    func buildBackgroundService() -> BackgroundSessionInterface {
        let appleBackgroundSessionService = AppleBackgroundServiceAssembly().build()
        return appleBackgroundSessionService
    }

    func buildNetworkManager(
        restService: RestInterface,
        backgroundSession: BackgroundSessionInterface
    ) -> NetworkInterface {
        let networkManager = NetworkManager(
            restService: restService,
            backgroundSession: backgroundSession)
        return networkManager
    }

    func buildRootController(
        restService: RestInterface,
        backgoundService: BackgroundSessionInterface,
        cacheManager: CacheInterface
    ) -> UINavigationController {
        let mainViewController = MainAssembly().build(
            restService: restService,
            backgoundService: backgoundService,
            cacheManager: cacheManager)
        let navigationController = UINavigationController(
            rootViewController: mainViewController)
        return navigationController
    }

    func buildRoutingManager(
        rootViewController: UINavigationController
    ) -> RoutingInterface {
        let routingManager = RoutingManager(
            rootViewController: rootViewController)
        return routingManager
    }

    func buildLoggerManager() -> LoggerInterface {
        let logger = LoggerManager()
        return logger
    }
}
