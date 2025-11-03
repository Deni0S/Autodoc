import Combine
import UIKit

final actor AppleBackgroundService {

    // MARK: - Properties

    private let session: URLSession
    private var sessionDelegates: [String: AppleBackgroundSessionDelegate]

    // MARK: - Initial

    init(
        session: URLSession,
        sessionDelegates: [String: AppleBackgroundSessionDelegate]
    ) {
        self.session = session
        self.sessionDelegates = sessionDelegates
    }
}

// MARK: - BackgroundSessionInterface

extension AppleBackgroundService: BackgroundSessionInterface {

    public func setupDelegate(
        for identifier: String,
        completionHandler: @escaping () -> Void
    ) async {
        let delegate = delegate(
            for: identifier)
        delegate.addCompletionHandler(
            completionHandler,
            for: session)
    }

    public func loadImage(
        for url: URL
    ) async -> UIImage? {
        let sessionIdentifier = "loadImage-\(UUID().uuidString)"
        let config = URLSessionConfiguration.background(
            withIdentifier: sessionIdentifier)
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        let delegate = delegate(
            for: sessionIdentifier)
        let session = URLSession(
            configuration: config,
            delegate: delegate,
            delegateQueue: nil)

        do {
            let task = session.downloadTask(with: url)
            let fileURL = try await withTaskCancellationHandler {
                try await withCheckedThrowingContinuation { continuation in
                    delegate.addDownloadCompletion(for: task) { result in
                        continuation.resume(with: result)
                    }
                    task.resume()
                }
            } onCancel: {
                task.cancel()
            }

            try Task.checkCancellation()
            let data = try Data(contentsOf: fileURL)
            try? FileManager.default.removeItem(at: fileURL)

            session.finishTasksAndInvalidate()
            removeDelegate(for: sessionIdentifier)

            guard let image = UIImage(data: data) else {
                return nil
            }
            return image
        } catch {
            Task {
                await AppScene.coordinator.managers.logger.debug(error: error.localizedDescription)
            }
            session.finishTasksAndInvalidate()
            removeDelegate(for: sessionIdentifier)
            return nil
        }
    }
}

// MARK: - PrivateMethods

private extension AppleBackgroundService {

    func delegate(
        for identifier: String
    ) -> AppleBackgroundSessionDelegate {
        if let delegate = sessionDelegates[identifier] {
            return delegate
        }
        let delegate = AppleBackgroundSessionDelegate()
        sessionDelegates[identifier] = delegate
        return delegate
    }

    func removeDelegate(
        for identifier: String
    ) {
        sessionDelegates.removeValue(forKey: identifier)
    }
}

