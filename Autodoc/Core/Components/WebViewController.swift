import UIKit
import WebKit

class WebViewController: UIViewController {

    // MARK: - Properties

    private let url: URL
    private var webView: WKWebView!
    private let activityIndicator: UIActivityIndicatorView

    // MARK: - Initial

    init(
        url: URL
    ) {
        self.url = url
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        setupActivityIndicator()
        loadURL()
    }
}

// MARK: - PrivateMethods

private extension WebViewController {

    func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
    }

    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

    }

    func loadURL() {
        webView.load(URLRequest(url: url))
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        didStartProvisionalNavigation navigation: WKNavigation!
    ) {
        activityIndicator.startAnimating()
    }

    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        activityIndicator.stopAnimating()
    }

    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        activityIndicator.stopAnimating()
        Task {
            await AppScene.coordinator.managers.logger.debug(error: error.localizedDescription)
        }
    }
}
