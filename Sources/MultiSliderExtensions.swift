//
//  MultiSliderExtensions.swift
//  MultiSlider
//
//  Created by Yonat Sharon on 20.05.2018.
//

import UIKit

extension CGFloat {
    func truncated(_ step: CGFloat) -> CGFloat {
        return step.isNormal ? self - remainder(dividingBy: step) : self
    }

    func rounded(_ step: CGFloat) -> CGFloat {
        guard step.isNormal && isNormal else { return self }
        return (self / step).rounded() * step
    }
}

extension CGPoint {
    func coordinate(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return y
        default:
            return x
        }
    }
}

extension CGRect {
    func size(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return height
        default:
            return width
        }
    }

    func bottom(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return maxY
        default:
            return minX
        }
    }

    func top(in axis: NSLayoutConstraint.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return minY
        default:
            return maxX
        }
    }
}

extension UIView {
    var diagonalSize: CGFloat { return hypot(frame.width, frame.height) }

    func removeFirstConstraint(where: (_: NSLayoutConstraint) -> Bool) {
        if let constrainIndex = constraints.firstIndex(where: `where`) {
            removeConstraint(constraints[constrainIndex])
        }
    }

    func addShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 0.5
    }
    
    /// Sweeter: Set constant attribute. Example: `constrain(.width, to: 17)`
    @discardableResult public func constrain(
        _ at: NSLayoutConstraint.Attribute,
        to: CGFloat = 0,
        ratio: CGFloat = 1,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        identifier: String? = nil
    ) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: self, attribute: at, relatedBy: relation,
            toItem: nil, attribute: .notAnAttribute, multiplier: ratio, constant: to
        )
        constraint.priority = priority
        constraint.identifier = identifier
        addConstraintWithoutConflict(constraint)
        return constraint
    }

    /// Sweeter: Pin subview at a specific place. Example: `constrain(label, at: .top)`
    @discardableResult public func constrain(
        _ subview: UIView,
        at: NSLayoutConstraint.Attribute,
        diff: CGFloat = 0,
        ratio: CGFloat = 1,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        identifier: String? = nil
    ) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: subview, attribute: at, relatedBy: relation,
            toItem: self, attribute: at, multiplier: ratio, constant: diff
        )
        constraint.priority = priority
        constraint.identifier = identifier
        addConstraintWithoutConflict(constraint)
        return constraint
    }

    /// Sweeter: Pin two subviews to each other. Example:
    ///
    /// `constrain(label, at: .leading, to: textField)`
    ///
    /// `constrain(textField, at: .top, to: label, at: .bottom, diff: 8)`
    @discardableResult public func constrain(
        _ subview: UIView,
        at: NSLayoutConstraint.Attribute,
        to subview2: UIView,
        at at2: NSLayoutConstraint.Attribute = .notAnAttribute,
        diff: CGFloat = 0,
        ratio: CGFloat = 1,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority = .required,
        identifier: String? = nil
    ) -> NSLayoutConstraint {
        let at2real = at2 == .notAnAttribute ? at : at2
        let constraint = NSLayoutConstraint(
            item: subview, attribute: at, relatedBy: relation,
            toItem: subview2, attribute: at2real, multiplier: ratio, constant: diff
        )
        constraint.priority = priority
        constraint.identifier = identifier
        addConstraintWithoutConflict(constraint)
        return constraint
    }

    /// Sweeter: Add subview pinned to specific places. Example: `addConstrainedSubview(button, constrain: .centerX, .centerY)`
    @discardableResult public func addConstrainedSubview(_ subview: UIView, constrain: NSLayoutConstraint.Attribute...) -> [NSLayoutConstraint] {
        return addConstrainedSubview(subview, constrainedAttributes: constrain)
    }

    @discardableResult func addConstrainedSubview(_ subview: UIView, constrainedAttributes: [NSLayoutConstraint.Attribute]) -> [NSLayoutConstraint] {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        return constrainedAttributes.map { self.constrain(subview, at: $0) }
    }

    func addConstraintWithoutConflict(_ constraint: NSLayoutConstraint) {
        removeConstraints(constraints.filter {
            constraint.firstItem === $0.firstItem
                && constraint.secondItem === $0.secondItem
                && constraint.firstAttribute == $0.firstAttribute
                && constraint.secondAttribute == $0.secondAttribute
        })
        addConstraint(constraint)
    }
    
    /// Sweeter: The color used to tint the view, as inherited from its superviews.
    public var actualTintColor: UIColor {
        var tintedView: UIView? = self
        while let currentView = tintedView, nil == currentView.tintColor {
            tintedView = currentView.superview
        }
        return tintedView?.tintColor ?? UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)
    }
}

extension Array where Element: UIView {
    mutating func removeViewsStartingAt(_ index: Int) {
        guard index >= 0 && index < count else { return }
        self[index ..< count].forEach { $0.removeFromSuperview() }
        removeLast(count - index)
    }
}

extension UIImageView {
    func blur(_ on: Bool) {
        if on {
            guard nil == viewWithTag(UIImageView.blurViewTag) else { return }
            let blurImage = image?.withRenderingMode(.alwaysTemplate)
            let blurView = UIImageView(image: blurImage)
            blurView.tag = UIImageView.blurViewTag
            blurView.tintColor = .white
            blurView.alpha = 0.5
            addConstrainedSubview(blurView, constrain: .top, .bottom, .left, .right)
            layer.shadowOpacity /= 2
        } else {
            guard let blurView = viewWithTag(UIImageView.blurViewTag) else { return }
            blurView.removeFromSuperview()
            layer.shadowOpacity *= 2
        }
    }

    static var blurViewTag: Int { return 898_989 } // swiftlint:disable:this numbers_smell
}

extension NSLayoutConstraint.Attribute {
    var opposite: NSLayoutConstraint.Attribute {
        switch self {
        case .left: return .right
        case .right: return .left
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        case .leftMargin: return .rightMargin
        case .rightMargin: return .leftMargin
        case .topMargin: return .bottomMargin
        case .bottomMargin: return .topMargin
        case .leadingMargin: return .trailingMargin
        case .trailingMargin: return .leadingMargin
        default: return self
        }
    }

    var inwardSign: CGFloat {
        switch self {
        case .top, .topMargin: return 1
        case .bottom, .bottomMargin: return -1
        case .left, .leading, .leftMargin, .leadingMargin: return 1
        case .right, .trailing, .rightMargin, .trailingMargin: return -1
        default: return 1
        }
    }

    var perpendicularCenter: NSLayoutConstraint.Attribute {
        switch self {
        case .left, .leading, .leftMargin, .leadingMargin, .right, .trailing, .rightMargin, .trailingMargin, .centerX:
            return .centerY
        default:
            return .centerX
        }
    }

    static func center(in axis: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Attribute {
        switch axis {
        case .vertical:
            return .centerY
        default:
            return .centerX
        }
    }

    static func top(in axis: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Attribute {
        switch axis {
        case .vertical:
            return .top
        default:
            return .right
        }
    }

    static func bottom(in axis: NSLayoutConstraint.Axis) -> NSLayoutConstraint.Attribute {
        switch axis {
        case .vertical:
            return .bottom
        default:
            return .left
        }
    }
}

extension CACornerMask {
    static func direction(_ attribute: NSLayoutConstraint.Attribute) -> CACornerMask {
        switch attribute {
        case .bottom:
            return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .top:
            return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .leading, .left:
            return [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .trailing, .right:
            return [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        default:
            return []
        }
    }
}

extension UIImage {
    static func circle(diameter: CGFloat = 29, width: CGFloat = 0.5, color: UIColor? = UIColor.lightGray.withAlphaComponent(0.5), fill: UIColor? = .white) -> UIImage? {
        let circleLayer = CAShapeLayer()
        circleLayer.fillColor = fill?.cgColor
        circleLayer.strokeColor = color?.cgColor
        circleLayer.lineWidth = width
        let margin = width * 2
        let circle = UIBezierPath(ovalIn: CGRect(x: margin, y: margin, width: diameter, height: diameter))
        circleLayer.bounds = CGRect(x: 0, y: 0, width: diameter + margin * 2, height: diameter + margin * 2)
        circleLayer.path = circle.cgPath
        UIGraphicsBeginImageContextWithOptions(circleLayer.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        circleLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension NSObject {
    func addObserverForAllProperties(
        observer: NSObject,
        options: NSKeyValueObservingOptions = [],
        context: UnsafeMutableRawPointer? = nil
    ) {
        performForAllKeyPaths { keyPath in
            addObserver(observer, forKeyPath: keyPath, options: options, context: context)
        }
    }

    func removeObserverForAllProperties(
        observer: NSObject,
        context: UnsafeMutableRawPointer? = nil
    ) {
        performForAllKeyPaths { keyPath in
            removeObserver(observer, forKeyPath: keyPath, context: context)
        }
    }

    func performForAllKeyPaths(_ action: (String) -> Void) {
        var count: UInt32 = 0
        guard let properties = class_copyPropertyList(object_getClass(self), &count) else { return }
        defer { free(properties) }
        for i in 0 ..< Int(count) {
            let keyPath = String(cString: property_getName(properties[i]))
            action(keyPath)
        }
    }
}
