//  Copyright © 2017 Aludio. All rights reserved.

import UIKit


/// Convenience AutoLayout extensions inspired by https://github.com/PureLayout/PureLayout
public final class Layout {
    public static let shared = Layout()
    private init() {}

    // MARK: Nested

    public struct View {
        let view: UIView
    }

    // MARK: Constraint

    @discardableResult
    public static func constraint(item item1: Any,
                           attribute attr1: NSLayoutAttribute,
                           toItem item2: Any? = nil,
                           attribute attr2: NSLayoutAttribute? = nil,
                           relation: NSLayoutRelation = .equal,
                           multiplier: CGFloat = 1,
                           constant: CGFloat = 0,
                           priority: UILayoutPriority? = nil,
                           identifier: String? = nil) -> NSLayoutConstraint {
        assert(Thread.isMainThread, "Layout APIs can only be used from the main thread")

        let constraint = NSLayoutConstraint(
            item: item1,
            attribute: attr1,
            relatedBy: relation,
            toItem: item2,
            attribute: attr2 ?? .notAnAttribute,
            multiplier: multiplier,
            constant: constant
        )
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.identifier = identifier

        (item1 as? UIView)?.translatesAutoresizingMaskIntoConstraints = false

        Layout.shared.install(constraints: [constraint])

        return constraint
    }

    // MARK: VFL

    @discardableResult
    public func vfl(_ format: String,
             options: NSLayoutFormatOptions = [],
             metrics: [String : Double]? = nil,
             views: [String: UIView]) -> [NSLayoutConstraint] {
        views.values.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        let constraints = NSLayoutConstraint.constraints(withVisualFormat: format, options: options, metrics: metrics, views: views)
        install(constraints: constraints)
        return constraints
    }

    // MARK: Batch Updates

    private var isCreatingConstraints = false
    private var createdConstraints = [[NSLayoutConstraint]]()

    /// Allows you to create, install and configure multiple constraints at the
    /// same time.
    @discardableResult
    public static func perform(_ closure: () -> Void) -> [NSLayoutConstraint] {
        let constraints = Layout.shared.create(closure)
        Layout.shared.install(constraints: constraints)
        return constraints
    }

    /// Creates all of the constraints in the block but prevents them from being
    /// automatically installed (activated).
    /// All constraints created from calls to the Layout API in the block are
    /// returned in a single array.
    ///
    /// WARNING: Calls can't be nested.
    public static func create(_ closure: () -> Void) -> [NSLayoutConstraint] {
        return Layout.shared.create(closure)
    }

    private func create(_ closure: () -> Void) -> [NSLayoutConstraint] {
        assert(!isCreatingConstraints, "Layout doesn't yet support nesting of `create` calls")

        createdConstraints.append([])
        isCreatingConstraints = true
        closure()
        isCreatingConstraints = false
        return createdConstraints.removeLast()
    }

    // MARK: Install

    private func install(constraints: [NSLayoutConstraint]) {
        if !isCreatingConstraints {
            NSLayoutConstraint.activate(constraints)
        } else {
            createdConstraints[createdConstraints.endIndex-1].append(contentsOf: constraints)
        }
    }
}


// MARK: Layout.View

extension UIView {
    public var al: Layout.View {
        return Layout.View(view: self)
    }
}


// MARK: Layout.Spacer

extension Layout {
    public static func spacer(height: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.al.setHeight(height).priority = UILayoutPriority(999)
        spacer.al.setWidth(1).priority = UILayoutPriority(1)
        return spacer
    }

    public static func spacer(width: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.al.setWidth(width).priority = UILayoutPriority(999)
        spacer.al.setHeight(1).priority = UILayoutPriority(1)
        return spacer
    }

    public static func spacer(minWidth: CGFloat) -> UIView {
        let spacer = UIView()
        spacer.al.setWidth(minWidth, relation: .greaterThanOrEqual)
        spacer.al.setWidth(minWidth).priority = UILayoutPriority(1)
        spacer.al.setHeight(1).priority = UILayoutPriority(1)
        return spacer
    }
}


// MARK: Misc

extension Layout {
    // Running on iPad (3.5")
    public static var isCompactHeight: Bool {
        return UIScreen.main.bounds.height < 538
    }
}
