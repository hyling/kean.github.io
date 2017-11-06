//  Copyright © 2017 Aludio. All rights reserved.

import UIKit


extension Layout {
    public enum Edge {
        case top, bottom, leading, trailing, left, right

        public var toAttribute: NSLayoutAttribute {
            switch self {
            case .top: return .top
            case .bottom: return .bottom
            case .leading: return .leading
            case .trailing: return .trailing
            case .left: return .left
            case .right: return .right
            }
        }
    }

    public enum Margin {
        case top, bottom, leading, trailing, left, right

        public var toAttribute: NSLayoutAttribute {
            switch self {
            case .top: return .topMargin
            case .bottom: return .bottomMargin
            case .leading: return .leadingMargin
            case .trailing: return .trailingMargin
            case .left: return .leftMargin
            case .right: return .rightMargin
            }
        }

        // Return corresponding edge.
        public var toEdge: NSLayoutAttribute {
            switch self {
            case .top: return .top
            case .bottom: return .bottom
            case .left: return .left
            case .right: return .right
            case .leading: return .leading
            case .trailing: return .trailing
            }
        }
    }

    public enum Axis {
        case vertical, horizontal

        public var toAttribute: NSLayoutAttribute {
            switch self {
            case .vertical: return .centerX
            case .horizontal: return .centerY
            }
        }

        public var toAttributeWithinMargins: NSLayoutAttribute {
            switch self {
            case .vertical: return .centerXWithinMargins
            case .horizontal: return .centerYWithinMargins
            }
        }
    }

    public enum Dimension {
        case width, height

        public var toAttribute: NSLayoutAttribute {
            switch self {
            case .width: return .width
            case .height: return .height
            }
        }
    }
}


// MARK: Helpers

extension NSLayoutRelation {
    var inverted: NSLayoutRelation {
        switch self {
        case .greaterThanOrEqual: return .lessThanOrEqual
        case .equal: return .equal
        case .lessThanOrEqual: return .greaterThanOrEqual
        }
    }
}

extension UIEdgeInsets {
    func insetForEdge(_ edge: Layout.Edge) -> CGFloat {
        switch edge {
        case .top: return top
        case .bottom: return bottom
        case .left, .leading: return left
        case .right, .trailing: return right
        }
    }
}
