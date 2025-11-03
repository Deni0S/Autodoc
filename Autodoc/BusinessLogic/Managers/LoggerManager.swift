import Foundation

// MARK: - Interfaces

protocol LoggerInterface {
    func debug(error: String) async
}

// MARK: - Manager

final actor LoggerManager {

}

// MARK: - LoggerInterface

extension LoggerManager: LoggerInterface {

    public func debug(
        error: String
    ) async {
        print(error)
    }
}
