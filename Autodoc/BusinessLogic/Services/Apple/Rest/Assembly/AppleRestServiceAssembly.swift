import Foundation

struct AppleRestServiceAssembly {

    // MARK: - PublicMethods

    public func build() -> RestInterface {
        let session: URLSession = .shared
        let decoder = JSONDecoder()
        let encoder: JSONEncoder = JSONEncoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        let service = AppleRestService(
            session: session,
            decoder: decoder,
            encoder: encoder)
        return service
    }
}
