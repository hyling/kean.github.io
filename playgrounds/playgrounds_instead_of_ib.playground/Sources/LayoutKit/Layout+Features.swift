//  Copyright © 2017 Aludio. All rights reserved.

import UIKit


// MARK: Layout: Edge

extension Layout.View {
    @discardableResult
    public func pinToSuperviewEdges(_ edges: [Layout.Edge] = [.top, .bottom, .leading, .trailing], insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        return edges.map {
            pinToSuperviewEdge($0, inset: insets.insetForEdge($0))
        }
    }

    @discardableResult
    public func pinToSuperviewEdge(_ edge: Layout.Edge, inset: CGFloat = 0.0, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        // The bottom, right, and trailing insets (and relations, if an inequality) are inverted to become offsets
        let shouldInvert = edge == .trailing || edge == .right || edge == .bottom
        return Layout.constraint(
            item: view,
            attribute: edge.toAttribute,
            toItem: superview,
            attribute: edge.toAttribute,
            relation: (shouldInvert ? relation.inverted : relation),
            multiplier: 1,
            constant: (shouldInvert ? -inset : inset)
        )
    }

    @discardableResult
    public func pinToSuperviewMargins(_ margins: [Layout.Margin] = [.top, .bottom, .leading, .trailing], relation: NSLayoutRelation = .equal) -> [NSLayoutConstraint] {
        return margins.map {
            pinToSuperviewMargin($0, relation: relation)
        }
    }

    @discardableResult
    public func pinToSuperviewMargins(excluding excludedMargin: Layout.Margin, relation: NSLayoutRelation = .equal) -> [NSLayoutConstraint] {
        var margins: [Layout.Margin] = [.top, .bottom, .leading, .trailing]
        if let idx = margins.index(of: excludedMargin) {
            margins.remove(at: idx)
        }
        return pinToSuperviewMargins(margins, relation: relation)
    }

    /// Pins the corresponding edge of the view to the given margin of superview.
    @discardableResult
    public func pinToSuperviewMargin( _ margin: Layout.Margin, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        let shouldInvert = margin == .trailing || margin == .right || margin == .bottom
        return Layout.constraint(
            item: view,
            attribute: margin.toEdge,
            toItem: superview,
            attribute: margin.toAttribute,
            relation: (shouldInvert ? relation.inverted : relation),
            multiplier: 1,
            constant: 0
        )
    }

    @discardableResult
    public func pinEdge(_ edge: Layout.Edge, toEdge otherEdge: Layout.Edge, of otherView: UIView, offset: CGFloat = 0, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: edge.toAttribute, toItem: otherView, attribute: otherEdge.toAttribute, relation: relation, multiplier: 1, constant: offset)
    }

    @discardableResult
    public func pinEdge(_ edge: Layout.Edge, to views: UIView...) -> [NSLayoutConstraint] {
        guard views.count > 0 else { return [] }
        return views.map {
            pinEdge(edge, toEdge: edge, of: $0)
        }
    }
}


// MARK: Layout: Safe Layout Guides

extension Layout.View {
    @discardableResult
    public func pinToSafeAreaGuides(_ edges: [Layout.Edge] = [.leading, .bottom, .trailing, .top], of vc: UIViewController) -> [NSLayoutConstraint] {
        return edges.map {
            pinEdge($0, toSafeAreaEdge: $0, of: vc)
        }
    }

    @discardableResult
    public func pinEdge(_ edge: Layout.Edge, toSafeAreaEdge toEdge: Layout.Edge, of vc: UIViewController, inset: CGFloat = 0, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        let toItem: Any
        if #available(iOS 11, *) {
            toItem = vc.view.safeAreaLayoutGuide
        } else {
            switch toEdge {
            case .top: toItem = vc.topLayoutGuide
            case .bottom: toItem = vc.bottomLayoutGuide
            case .leading, .trailing, .left, .right: toItem = vc.view
            }
        }

        // The bottom, right, and trailing insets (and relations, if an inequality) are inverted to become offsets
        let shouldInvert = toEdge == .trailing || toEdge == .right || toEdge == .bottom
        return Layout.constraint(
            item: view,
            attribute: edge.toAttribute,
            toItem: toItem,
            attribute: toEdge.toAttribute,
            relation: (shouldInvert ? relation.inverted : relation),
            multiplier: 1,
            constant: (shouldInvert ? -inset : inset)
        )
    }

    @discardableResult
    public func pinToTopLayoutGuide(of vc: UIViewController) -> NSLayoutConstraint {
        return pinEdge(.top, toSafeAreaEdge: .top, of: vc)
    }
}


// MARK: Layout: Axis

extension Layout.View {
    @discardableResult
    public func centerInSuperview() -> [NSLayoutConstraint] {
        return [alignToSuperviewAxis(.centerX), alignToSuperviewAxis(.centerY)]
    }

    @discardableResult
    public func centerInSuperviewMargins() -> [NSLayoutConstraint] {
        return [alignToSuperviewAxis(.centerXWithinMargins), alignToSuperviewAxis(.centerYWithinMargins)]
    }

    @discardableResult
    public func alignToSuperviewAxis(_ axis: Layout.Axis, offset: CGFloat = 0) -> NSLayoutConstraint {
        return alignToSuperviewAxis(axis.toAttribute, offset: offset)
    }

    @discardableResult
    public func alignToSuperviewMarginAxis(_ axis: Layout.Axis, offset: CGFloat = 0) -> NSLayoutConstraint {
        return alignToSuperviewAxis(axis.toAttributeWithinMargins, offset: offset)
    }

    private func alignToSuperviewAxis(_ axis: NSLayoutAttribute, offset: CGFloat = 0 ) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: axis, toItem: superview, attribute: axis, constant: offset)
    }

    @discardableResult
    public func alignAxis(_ axis: Layout.Axis, with otherView: UIView, offset: CGFloat = 0) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: axis.toAttribute, toItem: otherView, attribute: axis.toAttribute, relation: .equal, multiplier: 1, constant: offset)
    }

    /// Aligns both axis of the views.
    @discardableResult
    public func align(with other: UIView) -> [NSLayoutConstraint] {
        return [
            alignAxis(.horizontal, with: other),
            alignAxis(.vertical, with: other)
        ]
    }
}


// MARK: Layout: Dimension

extension Layout.View {
    @discardableResult
    public func setWidth(_ width: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: .width, relation: relation, constant: width)
    }

    @discardableResult
    public func setHeight(_ height: CGFloat, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: .height, relation: relation, constant: height)
    }

    @discardableResult
    public func setSize(_ size: CGSize) -> [NSLayoutConstraint] {
        return [setWidth(size.width), setHeight(size.height)]
    }

    @discardableResult
    public func matchDimension(_ dimension: Layout.Dimension, toDimension otherDimensions: Layout.Dimension, of otherView: UIView, offset: CGFloat = 0, multiplier: CGFloat = 1, relation: NSLayoutRelation = .equal) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: dimension.toAttribute, toItem: otherView, attribute: otherDimensions.toAttribute, relation: relation, multiplier: multiplier, constant: offset)
    }

    /// Matches both dimensions of the views.
    @discardableResult
    public func matchSize(of other: UIView) -> [NSLayoutConstraint] {
        return [
            matchDimension(.width, toDimension: .width, of: other),
            matchDimension(.height, toDimension: .height, of: other)
        ]
    }

    /// width = x * height
    @discardableResult
    public func setAspectRatio(_ ratio: CGFloat) -> NSLayoutConstraint {
        return Layout.constraint(item: view, attribute: .width, toItem: view, attribute: .height, relation: .equal, multiplier: ratio, constant: 0)
    }
}


// MARK: Priorities

extension Layout.View {
    public func setCompressionResistancePriority(_ priority: Float, for axis: UILayoutConstraintAxis) {
        view.setContentCompressionResistancePriority(UILayoutPriority(priority), for: axis)
    }

    public func setHuggingPriority(_ priority: Float, for axis: UILayoutConstraintAxis) {
        view.setContentHuggingPriority(UILayoutPriority(priority), for: axis)
    }
}


// MARK: Misc

extension Layout {
    public static func wrapped(_ view: UIView, _ insets: UIEdgeInsets = .zero) -> UIView {
        let wrapper = UIView()
        wrapper.layoutMargins = insets
        wrapper.addSubview(view)
        view.al.pinToSuperviewMargins()
        return wrapper
    }

    public static func stack(_ views: [UIView]) -> UIStackView {
        return UIStackView(arrangedSubviews: views)
    }
}


// MARK: Helpers

fileprivate extension Layout.View {
    var superview: UIView {
        assert(view.superview != nil, "View's superview must not be nil.\nView: \(view)")
        return view.superview!
    }
}
