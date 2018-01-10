//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


struct UserViewModel {
    let avatar: UIImage?
    let name: String
    let details: String
}

final class UserView: UIView {
    private let avatarView = UIImageView(style: { $0.contentMode = .scaleAspectFill })
    private let nameLabel = UILabel(style: Style.Label.headline, { $0.textColor = Color.mango })
    private let detailsLabel = UILabel(style: Style.Label.body, { $0.numberOfLines = 2 })

    private func _init() {
        avatarView.al.size.set(CGSize(width: 40, height: 40))

        let stack = UIStackView(
            style: { $0.spacing = 15; $0.alignment = .center },
            views: [
                avatarView,
                UIStackView(style: { $0.spacing = 3; $0.axis = .vertical },
                            views: [nameLabel, detailsLabel])
            ]
        )
        addSubview(stack) { $0.edges.pinToSuperview(insets: Insets(all: 15)) }
    }

    func display(_ vm: UserViewModel) {
        avatarView.image = vm.avatar
        nameLabel.text = vm.name
        detailsLabel.text = vm.details
    }

    override init(frame: CGRect) { super.init(frame: frame); _init() }
    required init?(coder: NSCoder) { super.init(coder: coder); _init() }
}


final class MyViewController : UIViewController {
    override func loadView() {
        self.view = UIView(style: { $0.backgroundColor = Color.lightGray })

        let userView = UserView(style: { $0.backgroundColor = .white })

        view.addSubview(userView) {
            $0.edges(.left, .right).pinToSuperview()
            $0.center.alignWithSuperview()
        }

        userView.display(
            UserViewModel(
                avatar: UIImage(named: "avatar"),
                name: "Alexander Grebenyuk",
                details: "Software Developer (Swift, Objective-C)"
            )
        )
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
