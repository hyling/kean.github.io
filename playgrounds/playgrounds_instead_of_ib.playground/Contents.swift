import UIKit
import PlaygroundSupport


final class ActivityViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let ratingView = RatingView()

        view.addSubview(ratingView)
        ratingView.al.centerInSuperview()
        ratingView.al.setHeight(40)

        ratingView.display(rating: 3.5)
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = ActivityViewController()
