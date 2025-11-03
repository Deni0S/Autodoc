import Combine
import Foundation
import UIKit

final actor AutodocNewsRestApi {

    // MARK: - Properties

    private let path = "/api/news"
    private let restService: RestInterface
    private let backgoundService: BackgroundSessionInterface
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initial

    init(
        restService: RestInterface,
        backgoundService: BackgroundSessionInterface
    ) {
        self.restService = restService
        self.backgoundService = backgoundService
    }

    // MARK: - PublicMethods

    public func fetch(
        page: UInt = 1,
        count: UInt = 15
    ) async -> AutodocNewsEntity? {
        do {
            let value = try await restService.get(
                baseURL: AutodocKeys.webAPI,
                path: "\(path)/\(page)/\(count)",
                responseType: AutodocNewsEntity.self)
                .receive(on: DispatchQueue.main)
                .values
                .first { _ in true }
            return value
        } catch {
            Task {
                await AppScene.coordinator.managers.logger.debug(error: error.localizedDescription)
            }
            return nil
        }
    }

    public func loadImage(
        for url: URL
    ) async -> UIImage? {
        await backgoundService.loadImage(for: url)
    }
}
