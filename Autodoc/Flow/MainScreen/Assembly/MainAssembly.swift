import UIKit

struct MainAssembly {

    // MARK: - PublicMethods

    public func build(
        restService: RestInterface,
        backgoundService: BackgroundSessionInterface,
        cacheManager: CacheInterface
    ) -> MainViewController {
        let newsAPI = AutodocNewsRestApi(
            restService: restService,
            backgoundService: backgoundService)
        let viewModel = MainViewModel(
            newsAPI: newsAPI,
            cacheAPI: cacheManager)
        let viewController = MainViewController(
            viewModel: viewModel)
        return viewController
    }
}
