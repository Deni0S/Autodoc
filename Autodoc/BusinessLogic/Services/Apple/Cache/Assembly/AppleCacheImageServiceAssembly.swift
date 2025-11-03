import UIKit

struct AppleCacheImageServiceAssembly {

    // MARK: - PublicMethods

    public func build() -> CacheImageInterface {
        let fileManager = FileManager.default
        let memoryCache = NSCache<NSString, UIImage>()
        let paths = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask)
        let fileManagerDirectory = paths[0]
            .appendingPathComponent("Apple.Cache.Image")
        try? fileManager.createDirectory(
            at: fileManagerDirectory,
            withIntermediateDirectories: true)
        let service = AppleCacheImageService(
            fileManager: fileManager,
            memoryCache: memoryCache,
            fileManagerDirectory: fileManagerDirectory)
        return service
    }
}
