import UIKit

final actor AppleCacheImageService {

    // MARK: - Properties

    private let fileManager: FileManager

    private let memoryCache: NSCache<NSString, UIImage>
    private let fileManagerDirectory: URL

    private let diskCacheCountLimit: Int
    private let diskCacheSizeLimit: Int

    // MARK: - Initial

    init(
        fileManager: FileManager,
        memoryCache: NSCache<NSString, UIImage>,
        fileManagerDirectory: URL
    ) {
        self.fileManager = fileManager
        self.memoryCache = memoryCache
        self.fileManagerDirectory = fileManagerDirectory

        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 200 * 1024 * 1024
        diskCacheCountLimit = 1000
        diskCacheSizeLimit = 500 * 1024 * 1024

        Task {
            await cleanupOldFiles()
        }
    }
}

// MARK: - CacheImageInterface

extension AppleCacheImageService: CacheImageInterface {

    public func imageFromCache(
        for key: String
    ) async -> UIImage? {
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }

        let fileURL = fileURL(for: key)
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            return nil
        }

        updateAccessDate(for: fileURL)
        let cost = calculateImageCost(image)
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)

        return image
    }

    public func imageToCache(
        _ image: UIImage,
        for key: String
    ) async {
        let cost = calculateImageCost(image)
        memoryCache.setObject(image, forKey: key as NSString, cost: cost)

        Task(priority: .background) {
            let fileURL = fileURL(for: key)
            if let data = image.jpegData(compressionQuality: 0.7) ?? image.pngData() {
                try? data.write(to: fileURL)

                await self.cleanupOldFilesIfNeeded()
            }
        }
    }

    public func clearImageCache() async {
        Task {
            await clearMemoryCache()
        }
        Task {
            await clearDiskCache()
        }
    }
}

// MARK: - MemoryErrorInterface

extension AppleCacheImageService: MemoryErrorInterface {

    public func clearMemoryCache() async {
        memoryCache.removeAllObjects()
    }

    public func clearDiskCache() async {
        try? fileManager.removeItem(
            at: fileManagerDirectory)
        try? fileManager.createDirectory(
            at: fileManagerDirectory,
            withIntermediateDirectories: true)
    }

}

// MARK: - PrivateMethods

private extension AppleCacheImageService {

    func fileURL(
        for key: String
    ) -> URL {
        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        let pathComponent = String("\(encodedKey)".prefix(100))
        return fileManagerDirectory.appendingPathComponent(pathComponent)
    }

    func calculateImageCost(
        _ image: UIImage
    ) -> Int {
        let size = image.size
        let cost = Int(size.width * size.height * 4)
        return max(cost, 1)
    }

    func updateAccessDate(for fileURL: URL) {
        try? fileManager.setAttributes(
            [.modificationDate: Date()],
            ofItemAtPath: fileURL.path
        )
    }

    func cleanupOldFilesIfNeeded() async {
        if await shouldCleanupFiles() {
            await cleanupOldFiles()
        }
    }

    func shouldCleanupFiles() async -> Bool {
        guard let files = try? fileManager.contentsOfDirectory(
            at: fileManagerDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else { return false }

        let totalSize = files.reduce(0) { total, fileURL in
            guard let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let size = resources.fileSize else { return total }
            return total + size
        }

        return files.count > diskCacheCountLimit || totalSize > diskCacheSizeLimit
    }

    func cleanupOldFiles() async {
        guard let files = try? fileManager.contentsOfDirectory(
            at: fileManagerDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey]
        ) else { return }

        let sortedFiles = files.sorted { first, second in
            let firstDate = (try? first.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let secondDate = (try? second.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return firstDate < secondDate
        }

        var currentCount = sortedFiles.count
        var currentSize = sortedFiles.reduce(0) { total, fileURL in
            guard let resources = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                  let size = resources.fileSize else { return total }
            return total + size
        }

        for file in sortedFiles {
            if currentCount <= diskCacheCountLimit / 2 && currentSize <= diskCacheSizeLimit / 2 {
                break
            }

            guard let resources = try? file.resourceValues(forKeys: [.fileSizeKey]),
                  let size = resources.fileSize else { continue }

            try? fileManager.removeItem(at: file)
            currentCount -= 1
            currentSize -= size
        }
    }
}
