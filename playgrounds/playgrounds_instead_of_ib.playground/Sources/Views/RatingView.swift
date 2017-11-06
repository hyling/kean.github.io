import UIKit


public final class RatingView: UIView {
    private let imageViews = Array((0..<5).map { _ in UIImageView() })

    public override init(frame: CGRect) {
        super.init(frame: frame)
        imageViews.forEach {
            $0.al.setAspectRatio(1)
        }
        let stack = Layout.stack(imageViews).then {
            $0.spacing = 5
        }
        addSubview(stack)
        stack.al.pinToSuperviewMargins()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func display(rating: Double) {
        zip(imageViews, RatingView.imageTypes(for: rating)).forEach { view, type in
            view.tintColor = Color.gold
            view.image = RatingView.getImage(type: type)?.withRenderingMode(.alwaysTemplate)
        }
    }

    private enum RatingImageType {
        case empty, half, full
    }

    private static func imageTypes(for rating: Double) -> [RatingImageType] {
        let rating = Int(round(rating * 2))
        return Array(1...5).map {
            if rating >= ($0 * 2) { return .full }
            if rating >= ($0 * 2 - 1) { return .half }
            return .empty
        }
    }

    private static func getImage(type: RatingImageType) -> UIImage? {
        switch type {
        case .empty: return UIImage(named: "start_empty")
        case .half: return UIImage(named: "star-half-empty")
        case .full: return UIImage(named: "star-filled")
        }
    }
}
