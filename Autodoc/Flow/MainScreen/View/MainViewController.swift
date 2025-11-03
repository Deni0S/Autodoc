import Combine
import UIKit

final class MainViewController: UIViewController {

    // MARK: - Properties

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<MainViewSectionType, MainRegularItem>!
    private var leftButton: UIBarButtonItem!
    private var rightButton: UIBarButtonItem!
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initial

    init(
        viewModel: MainViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(
        coder: NSCoder
    ) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupUI()
        setupDataSource()

        viewModel.loadNextData()
        viewModel.$viewState
            .sink { [weak self] state in
                DispatchQueue.main.async {
                    self?.stateHandler(state)
                }
            }
            .store(in: &cancellables)
    }

    override func viewDidAppear(
        _ animated: Bool
    ) {
        super.viewDidAppear(animated)
        beginRefreshing()
    }
}

// MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        if let url = URL(string: item.fullURL) {
            let webViewController = WebViewController(url: url)
            webViewController.modalPresentationStyle = .pageSheet
            present(webViewController, animated: true)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let numberOfItems = dataSource.snapshot().numberOfItems
        guard let maxCell = indexPath.max(),
              numberOfItems - maxCell < viewModel.pullNews,
              case .loaded(_) = viewModel.viewState else {
            return
        }
        viewModel.loadNextData()
    }
}

// MARK: - PrivateMethods

private extension MainViewController {

    func setupUI() {
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("News", comment: "")

        leftButton = UIBarButtonItem(
                    image: UIImage(systemName: "arrow.clockwise"),
                    style: .plain,
                    target: self,
                    action: #selector(leftButtonTapped))
        leftButton.tintColor = .accent
        navigationItem.leftBarButtonItem = leftButton

        rightButton = UIBarButtonItem(
                    image: UIImage(systemName: "trash"),
                    style: .plain,
                    target: self,
                    action: #selector(rightButtonTapped))
        rightButton.tintColor = .accent
        navigationItem.rightBarButtonItem = rightButton

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view.addSubview(collectionView)

        collectionView.register(MainRegularCell.self, forCellWithReuseIdentifier: MainRegularCell.description())
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = MainViewSectionType(rawValue: sectionIndex) else { fatalError() }

            switch section {
            case .regular:
                return self?.createRegularSection()
            }
        }
    }

    func createRegularSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(300)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 16, trailing: 16)

        return section
    }

    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MainViewSectionType, MainRegularItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            self?.cellForItemAt(collectionView: collectionView, indexPath: indexPath, item: item)
        }
    }

    func cellForItemAt(
        collectionView: UICollectionView,
        indexPath: IndexPath,
        item: MainRegularItem
    ) -> UICollectionViewCell {
        guard let section = MainViewSectionType(rawValue: indexPath.section) else {
            fatalError("Unknown section")
        }

        switch section {
        case .regular:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MainRegularCell.description(),
                for: indexPath) as! MainRegularCell

            let imageTask = Task(priority: .userInitiated) {
                let image = await viewModel.image(for: item.imageURL)
                await MainActor.run {
                    cell.configureImage(image, from: item.imageURL)
                }
            }

            cell.configure(
                with: item,
                imageTask: imageTask)

            return cell
        }
    }

    func applySnapshot(
        _ items: [MainViewSectionType: [MainRegularItem]]
    ) {
        var snapshot = dataSource.snapshot()

        for section in MainViewSectionType.allCases {
            if !snapshot.sectionIdentifiers.contains(section) {
                snapshot.appendSections([section])
            }
            if let items = items[section] {
                snapshot.appendItems(items, toSection: section)
            }
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }

    func stateHandler(
        _ state: MainViewStateType
    ) {
        switch state {
        case .isLoading:
            leftButton.isEnabled = false
            rightButton.isEnabled = false
            leftButton.image = UIImage(systemName: "arrow.down.circle")
            rightButton.image = UIImage(systemName: "arrow.down.circle")
        case .final:
            leftButton.isEnabled = true
            rightButton.isEnabled = true
            leftButton.image = UIImage(systemName: "arrow.clockwise")
            rightButton.image = UIImage(systemName: "trash")
            collectionView.refreshControl?.endRefreshing()
        case let .loaded(items):
            applySnapshot(items)
            leftButton.isEnabled = true
            rightButton.isEnabled = true
            leftButton.image = UIImage(systemName: "arrow.clockwise")
            rightButton.image = UIImage(systemName: "trash")
            collectionView.refreshControl?.endRefreshing()
        }
    }

    func beginRefreshing() {
        collectionView.refreshControl?.beginRefreshing()
        let offset = CGPoint(x: 0, y: -(collectionView.refreshControl?.frame.height ?? 0))
        collectionView.setContentOffset(offset, animated: true)
    }

    @objc func refreshData() {
        rightButton.isEnabled = false
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot, animatingDifferences: true)
        viewModel.refresh()
    }

    @objc func leftButtonTapped() {
        leftButton.isEnabled = false
        refreshData()
    }

    @objc func rightButtonTapped() {
        rightButton.isEnabled = false
        viewModel.clearCache()
        refreshData()
        beginRefreshing()
    }
}
