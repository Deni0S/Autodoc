import UIKit

class AppleBackgroundSessionDelegate: NSObject {

    private var completionHandlers: [URLSession: () -> Void] = [:]
    private var downloadCompletions: [URLSessionDownloadTask: (Result<URL, Error>) -> Void] = [:]

    // MARK: - PublicMethods

    public func addCompletionHandler(
        _ handler: @escaping () -> Void,
        for session: URLSession
    ) {
        completionHandlers[session] = handler
    }

    public func addDownloadCompletion(
        for task: URLSessionDownloadTask,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        downloadCompletions[task] = completion
    }
}

// MARK: - URLSessionDownloadDelegate

extension AppleBackgroundSessionDelegate: URLSessionDownloadDelegate {

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        if let completion = downloadCompletions[downloadTask] {
            completion(.success(location))
            downloadCompletions.removeValue(forKey: downloadTask)
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let downloadTask = task as? URLSessionDownloadTask,
              let completion = downloadCompletions[downloadTask] else { return }

        if let error = error {
            completion(.failure(error))
        }
        downloadCompletions.removeValue(forKey: downloadTask)
    }

    func urlSessionDidFinishEvents(
        forBackgroundURLSession session: URLSession
    ) {
        DispatchQueue.main.async {
            if let completionHandler = self.completionHandlers[session] {
                completionHandler()
                self.completionHandlers.removeValue(forKey: session)
            }
        }
    }
}
