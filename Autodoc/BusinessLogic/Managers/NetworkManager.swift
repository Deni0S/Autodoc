import Combine
import Foundation
import UIKit

// MARK: - Interfaces

protocol NetworkInterface {
    var restService: RestInterface { get async }
    var backgroundService: BackgroundSessionInterface { get async }
}

protocol RestInterface {
    func get<T: Decodable>(baseURL: String, path: String, responseType: T.Type) async -> AnyPublisher<T, NetworkErrorType>
    func post<T: Decodable, U: Encodable>(baseURL: String, path: String, body: U, responseType: T.Type) async -> AnyPublisher<T, NetworkErrorType>
    func put<T: Decodable, U: Encodable>(baseURL: String, path: String, body: U, responseType: T.Type) async -> AnyPublisher<T, NetworkErrorType>
    func delete(baseURL: String, path: String) async -> AnyPublisher<AppleRestEmptyResponseEntity, NetworkErrorType>
}

protocol BackgroundSessionInterface {
    func setupDelegate(for identifier: String, completionHandler: @escaping () -> Void) async
    func loadImage(for url: URL) async -> UIImage?
}

// MARK: - Manager

final actor NetworkManager: NetworkInterface {

    // MARK: - Properties

    let restService: RestInterface
    let backgroundService: BackgroundSessionInterface

    // MARK: - Initial

    init(
        restService: RestInterface,
        backgroundSession: BackgroundSessionInterface
    ) {
        self.restService = restService
        self.backgroundService = backgroundSession
    }
}
