import UIKit

class MainRegularCell: UICollectionViewCell {

    // MARK: - Properties

    private var currentImageURL: String?
    private let imageSkeleton = SkeletonView()
    private var currentTask: Task<(), Never>?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .accent
        label.backgroundColor = .systemBackground.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0.9
        return imageView
    }()

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupSkeletonViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        currentImageURL = nil
    }

    // MARK: - PublicMethods

    public func configure(
        with item: MainRegularItem,
        imageTask: Task<(), Never>
    ) {
        currentImageURL = item.imageURL
        currentTask?.cancel()
        currentTask = nil
        currentTask = imageTask

        titleLabel.text = item.title

        showSkeleton()
    }

    public func configureImage(
        _ image: UIImage?,
        from urlString: String
    ) {
        guard currentImageURL == urlString else { return }

        if let image = image {
            setupImage(image, from: urlString)
        } else {
            setupPlaceholder()
        }

        hideSkeleton()

        setNeedsLayout()
        layoutIfNeeded()
    }
}

// MARK: - SkeletonDisplayable

extension MainRegularCell: SkeletonDisplayableInterface {

    func showSkeleton() {
        backgroundImageView.isHidden = true

        imageSkeleton.isHidden = false
        imageSkeleton.startAnimating()

        containerView.backgroundColor = .clear
    }

    func hideSkeleton() {
        backgroundImageView.isHidden = false
        titleLabel.isHidden = false

        imageSkeleton.isHidden = true
        imageSkeleton.stopAnimating()

        containerView.backgroundColor = .clear
    }
}

// MARK: - PrivateMethods

private extension MainRegularCell {

    func setupUI() {
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])

        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 12
        containerView.layer.cornerCurve = .continuous
        containerView.backgroundColor = .secondarySystemBackground

        containerView.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        let titleOverlay = UIView()
        titleOverlay.translatesAutoresizingMaskIntoConstraints = false
        titleOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        titleOverlay.layer.cornerRadius = 8
        titleOverlay.layer.cornerCurve = .continuous
        titleOverlay.isUserInteractionEnabled = false
        containerView.addSubview(titleOverlay)

        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .left
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOpacity = 0.4
        titleLabel.layer.shadowRadius = 2
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleLabel.layer.masksToBounds = false

        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 8
        let overlayInset: CGFloat = 8

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalPadding),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -verticalPadding),

            titleOverlay.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -overlayInset),
            titleOverlay.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -overlayInset),
            titleOverlay.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: overlayInset),
            titleOverlay.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: overlayInset)
        ])

        containerView.bringSubviewToFront(titleOverlay)
        containerView.bringSubviewToFront(titleLabel)
    }

    func setupSkeletonViews() {
        containerView.addSubview(imageSkeleton)
        imageSkeleton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageSkeleton.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageSkeleton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageSkeleton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            imageSkeleton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        containerView.sendSubviewToBack(imageSkeleton)
    }

    func setupImage(
        _ image: UIImage,
        from urlString: String
    ) {
        UIView.transition(
            with: backgroundImageView,
            duration: 0.3,
            options: .transitionCrossDissolve
        ) { [self] in
            backgroundImageView.image = image
            backgroundImageView.isHidden = false
            imageSkeleton.stopAnimating()
            imageSkeleton.isHidden = true
        }
    }

    func setupPlaceholder() {
        backgroundImageView.image = UIImage(systemName: "photo")?
            .withTintColor(.gray, renderingMode: .alwaysTemplate)
        backgroundImageView.tintColor = .accent
        backgroundImageView.isHidden = false
        imageSkeleton.stopAnimating()
        imageSkeleton.isHidden = true
    }
}
