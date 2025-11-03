import UIKit

// MARK: - Interfaces

protocol SkeletonDisplayableInterface {
    func showSkeleton()
    func hideSkeleton()
}

// MARK: - View

class SkeletonView: UIView {

    // MARK: - Properties

    private let gradientLayer = CAGradientLayer()
    private let animationKey = "skeletonAnimation"

    // MARK: - Initial

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSkeleton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - LifeCycle

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray6.cgColor,
            UIColor.systemGray5.cgColor
        ]
        if !isHidden {
            startAnimating()
        }
    }

    // MARK: - PublicMethods

    public func startAnimating() {
        isHidden = false
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: animationKey)
    }

    public func stopAnimating() {
        isHidden = true
        gradientLayer.removeAnimation(forKey: animationKey)
    }
}

// MARK: - PrivateMethods

private extension SkeletonView {

    func setupSkeleton() {
        gradientLayer.colors = [
            UIColor.systemGray5.cgColor,
            UIColor.systemGray6.cgColor,
            UIColor.systemGray5.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = 4
        layer.addSublayer(gradientLayer)

        isHidden = true
    }
}
