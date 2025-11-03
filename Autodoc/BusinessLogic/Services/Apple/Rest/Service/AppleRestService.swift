import Combine
import UIKit

final actor AppleRestService {

    // MARK: - Properties

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // MARK: - Initial

    init(
        session: URLSession,
        decoder: JSONDecoder,
        encoder: JSONEncoder
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
}

// MARK: - RestInterface

extension AppleRestService: RestInterface {

    public func get<T: Decodable>(
        baseURL: String,
        path: String,
        responseType: T.Type
    ) async -> AnyPublisher<T, NetworkErrorType> {
        let requestEntity = AppleRestRequestEntity(
            method: .get,
            baseURL: baseURL,
            path: path,
            responseType: responseType)
        return request(requestEntity)
    }

    public func post<T: Decodable, U: Encodable>(
        baseURL: String,
        path: String,
        body: U,
        responseType: T.Type
    ) async -> AnyPublisher<T, NetworkErrorType> {
        let bodyData = try? encoder.encode(body)
        let requestEntity = AppleRestRequestEntity(
            method: .post,
            baseURL: baseURL,
            path: path,
            body: bodyData,
            responseType: responseType)
        return request(requestEntity)
    }

    public func put<T: Decodable, U: Encodable>(
        baseURL: String,
        path: String,
        body: U,
        responseType: T.Type
    ) async -> AnyPublisher<T, NetworkErrorType> {
        let bodyData = try? encoder.encode(body)
        let requestEntity = AppleRestRequestEntity(
            method: .put,
            baseURL: baseURL,
            path: path,
            body: bodyData,
            responseType: responseType)
        return request(requestEntity)
    }

    public func delete(
        baseURL: String,
        path: String
    ) async -> AnyPublisher<AppleRestEmptyResponseEntity, NetworkErrorType> {
        let requestEntity = AppleRestRequestEntity(
            method: .delete,
            baseURL: baseURL,
            path: path,
            responseType: AppleRestEmptyResponseEntity.self)
        return request(requestEntity)
    }
}

// MARK: - PrivateMethods

private extension AppleRestService {

    func createRequest<T>(
        from entity: AppleRestRequestEntity<T>
    ) -> URLRequest? {
        guard var urlComponents = URLComponents(string: entity.baseURL) else {
            return nil
        }

        urlComponents.path = entity.path
        urlComponents.queryItems = entity.queryItems

        guard let url = urlComponents.url else {
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = entity.method.rawValue
        urlRequest.httpBody = entity.body

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        entity.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }

    func request<T: Decodable>(
        _ entity: AppleRestRequestEntity<T>
    ) -> AnyPublisher<T, NetworkErrorType> {
        guard let urlRequest = createRequest(from: entity) else {
            return Fail(error: NetworkErrorType.invalidURL)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkErrorType.invalidResponse
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkErrorType.statusCode(httpResponse.statusCode)
                }

                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if let networkError = error as? NetworkErrorType {
                    return networkError
                } else if let decodingError = error as? DecodingError {
                    return NetworkErrorType.decodingError(decodingError)
                } else {
                    return NetworkErrorType.unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
