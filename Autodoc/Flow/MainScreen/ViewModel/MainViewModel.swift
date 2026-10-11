import UIKit

final class MainViewModel: ObservableObject {

    // MARK: - Properties

    @Published private(set) var viewState = MainViewStateType.isLoading

    private let newsAPI: AutodocNewsRestApi
    private let cacheAPI: CacheInterface
    private var currentPage: UInt = 1
    private let countNews: UInt = 15
    private(set) var pullNews: Int = 5

    // MARK: - Initial

    init(
        newsAPI: AutodocNewsRestApi,
        cacheAPI: CacheInterface
    ) {
        self.newsAPI = newsAPI
        self.cacheAPI = cacheAPI
    }

    // MARK: - PublicMethods

    public func loadNextData() {
        guard viewState != .final else { return }
        viewState = .isLoading
        Task {
            if let entity = await newsAPI.fetch(page: currentPage, count: countNews) {
                let newItems: [MainRegularItem] = entity.news.compactMap {
                    if let id = $0.id,
                       let title = $0.title,
                       let imageURL = $0.titleImageUrl,
                       let fullUrl = $0.fullUrl {
                        MainRegularItem(
                            id: id,
                            title: title,
                            imageURL: imageURL,
                            fullURL: fullUrl)
                    } else {
                        nil
                    }
                }
                viewState = .loaded(items: [.regular: newItems])
                if entity.news.count == countNews {
                    currentPage += 1
                } else {
                    viewState = .final
                }
            } else {
                viewState = .loaded(items: [:])
            }
        }
    }

    public func refresh() {
        viewState = .isLoading
        currentPage = 1
        loadNextData()
    }

    public func clearCache() {
        Task(priority: .userInitiated) {
            await cacheAPI.imageService.clearImageCache()
        }
    }

    public func image(
        for key: String
    ) async -> UIImage? {
        guard let url = URL(string: key) else {
            return nil
        }

        if let cachedImage = await cacheAPI.imageService.imageFromCache(for: key) {
            return cachedImage
        }

        if let loadedImage = await newsAPI.loadImage(for: url) {
            Task(priority: .medium) {
                await cacheAPI.imageService.imageToCache(loadedImage, for: key)
            }
            return loadedImage
        }

        return nil
    }
}
