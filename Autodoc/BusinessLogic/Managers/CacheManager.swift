import UIKit

// MARK: - Interfaces

protocol CacheInterface {
    var imageService: CacheImageInterface { get async }
}

protocol CacheImageInterface: MemoryErrorInterface {
    func imageFromCache(for key: String) async -> UIImage?
    func imageToCache(_ image: UIImage, for key: String) async
    func clearImageCache() async
}

protocol MemoryErrorInterface {
    func clearMemoryCache() async
    func clearDiskCache() async
}

// MARK: - Manager

final actor CacheManager: CacheInterface {

    // MARK: - Properties

    let imageService: CacheImageInterface

    // MARK: - Initial

    init(
        imageService: CacheImageInterface
    ) {
        self.imageService = imageService

        Task {
            await setupWarningHandler()
        }
    }
}

// MARK: - PrivateMethods

private extension CacheManager {

    func setupWarningHandler() async {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.imageService.clearMemoryCache()
            }
        }

        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: .NSUbiquityIdentityDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { [weak self] in
                await self?.imageService.clearDiskCache()
            }
        }
        #endif
    }
}
