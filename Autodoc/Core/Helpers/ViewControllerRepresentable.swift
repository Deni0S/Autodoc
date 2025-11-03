import SwiftUI

struct ViewControllerRepresentable: UIViewControllerRepresentable, Identifiable {

    // MARK: - Properties

    var id: String

    private let controller: UIViewController

    // MARK: - Initial

    init(
        _ controller: UIViewController
    ) {
        self.controller = controller
        id = UUID().uuidString
    }

    // MARK: - PublicMethods
    
    public func makeUIViewController(
        context: Context
    ) -> UIViewController {
        controller
    }

    public func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {

    }
}
