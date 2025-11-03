import Foundation

struct AppleBackgroundServiceAssembly {

    // MARK: - PublicMethods

    public func build() -> BackgroundSessionInterface {
        let session: URLSession = .shared
        let service = AppleBackgroundService(
            session: session,
            sessionDelegates: [:])
        return service
    }
}
