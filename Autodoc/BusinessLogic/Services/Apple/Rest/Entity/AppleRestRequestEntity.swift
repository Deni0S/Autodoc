import Foundation

struct AppleRestRequestEntity<T> {
    enum MethodType: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    let method: MethodType
    let baseURL: String
    let path: String
    let queryItems: [URLQueryItem]?
    let body: Data?
    let headers: [String: String]?
    let responseType: T.Type

    init(
        method: MethodType = .get,
        baseURL: String,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) {
        self.method = method
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
        self.body = body
        self.headers = headers
        self.responseType = responseType
    }
}
