import UIKit

public protocol ConstraintValue { }
extension Int: ConstraintValue { }
extension UInt: ConstraintValue { }
extension Float: ConstraintValue { }
extension Double: ConstraintValue { }
extension CGFloat: ConstraintValue { }

extension ConstraintValue {
    public var value: CGFloat {
        if let value = self as? Int { return CGFloat(value) }
        if let value = self as? UInt { return CGFloat(value) }
        if let value = self as? Float { return CGFloat(value) }
        if let value = self as? Double { return CGFloat(value) }
        if let value = self as? CGFloat { return value }
        return 0
    }
}

public protocol ConstraintAnchor { }
public struct SafeAnchor: ConstraintAnchor { fileprivate var view: UIView }
extension UIView: ConstraintAnchor { public var safe: SafeAnchor { SafeAnchor(view: self) } }
extension NSLayoutYAxisAnchor: ConstraintAnchor { }
extension NSLayoutXAxisAnchor: ConstraintAnchor { }
extension NSLayoutDimension: ConstraintAnchor { }
extension ConstraintAnchor {
    fileprivate func anchor(_ type: ConstraintType) -> Any? {
        if let view = self as? UIView { return type.anchor(view) }
        if let view = self as? SafeAnchor { return type.safe(view.view) }
        if let value = self as? NSLayoutYAxisAnchor { return value }
        if let value = self as? NSLayoutXAxisAnchor { return value }
        if let value = self as? NSLayoutDimension { return value }
        return nil
    }
    fileprivate func constraint(_ value: Any) -> NSLayoutConstraint? {
        if let layout = self as? NSLayoutDimension, let anchor = value as? NSLayoutDimension {
            return layout.constraint(equalTo: anchor)
        }
        if let layout = self as? NSLayoutXAxisAnchor, let anchor = value as? NSLayoutXAxisAnchor {
            return layout.constraint(equalTo: anchor)
        }
        if let layout = self as? NSLayoutYAxisAnchor, let anchor = value as? NSLayoutYAxisAnchor {
            return layout.constraint(equalTo: anchor)
        }
        if let layout = self as? NSLayoutDimension, let value = value as? CGFloat {
            return layout.constraint(equalToConstant: value)
        }
        return nil
    }
    fileprivate func constraint(_ anchor: Any?, _ multiplier: CGFloat) -> NSLayoutConstraint? {
        if let layout = self as? NSLayoutDimension, let anchor = anchor as? NSLayoutDimension {
            return layout.constraint(equalTo: anchor, multiplier: multiplier)
        }
        if let layout = self as? NSLayoutXAxisAnchor, let anchor = anchor as? NSLayoutXAxisAnchor {
            return layout.constraint(equalTo: anchor)
        }
        if let layout = self as? NSLayoutYAxisAnchor, let anchor = anchor as? NSLayoutYAxisAnchor {
            return layout.constraint(equalTo: anchor)
        }
        return nil
    }
}

public enum ConstraintType: String {
    case x, y, top, bottom, left, right, leading, trailing, width, height
    func anchor(_ view: UIView) -> ConstraintAnchor {
        switch self {
        case .x: return view.centerXAnchor
        case .y: return view.centerYAnchor
        case .top: return view.topAnchor
        case .bottom: return view.bottomAnchor
        case .left: return view.leftAnchor
        case .right: return view.rightAnchor
        case .leading: return view.leadingAnchor
        case .trailing: return view.trailingAnchor
        case .width: return view.widthAnchor
        case .height: return view.heightAnchor
        }
    }
    func safe(_ view: UIView) -> ConstraintAnchor {
        switch self {
        case .x: return view.safeXAnchor
        case .y: return view.safeYAnchor
        case .top: return view.safeTopAnchor
        case .bottom: return view.safeBottomAnchor
        case .left: return view.safeLeftAnchor
        case .right: return view.safeRightAnchor
        case .leading: return view.safeLeadingAnchor
        case .trailing: return view.safeTrailingAnchor
        case .width: return view.safeWidthAnchor
        case .height: return view.safeHeightAnchor
        }
    }
    
    func layout(_ layout: UILayoutGuide) -> ConstraintAnchor? {
        switch self {
        case .top: return layout.topAnchor
        case .bottom: return layout.bottomAnchor
        case .left: return layout.leftAnchor
        case .right: return layout.rightAnchor
        case .leading: return layout.leadingAnchor
        case .trailing: return layout.trailingAnchor
        default: return nil
        }
    }
    func opposite(_ layout: UILayoutGuide) -> ConstraintAnchor? {
        switch self {
        case .top: return layout.bottomAnchor
        case .bottom: return layout.topAnchor
        case .left: return layout.rightAnchor
        case .right: return layout.leftAnchor
        case .leading: return layout.trailingAnchor
        case .trailing: return layout.leadingAnchor
        default: return nil
        }
    }
    func dimension(_ layout: UILayoutGuide) -> ConstraintAnchor? {
        switch self {
        case .top: return layout.heightAnchor
        case .bottom: return layout.heightAnchor
        case .left: return layout.widthAnchor
        case .right: return layout.widthAnchor
        case .leading: return layout.widthAnchor
        case .trailing: return layout.widthAnchor
        default: return nil
        }
    }
    func dimension(_ layout: UIView) -> ConstraintAnchor? {
        switch self {
        case .top: return layout.heightAnchor
        case .bottom: return layout.heightAnchor
        case .left: return layout.widthAnchor
        case .right: return layout.widthAnchor
        case .leading: return layout.widthAnchor
        case .trailing: return layout.widthAnchor
        default: return nil
        }
    }
    var layout: Bool {
        switch self {
        case .width, .height: return false
        default: return true
        }
    }
}

extension UIView {
    @discardableResult public
    func constraint(_ type: ConstraintType, anchor: ConstraintAnchor?, value: ConstraintValue? = nil,
                    _ identifier: String? = nil, _ active: Bool = true) -> Self {
        guard let anchor = anchor?.anchor(type) else { return self }
        let value = value?.value ?? 0
        
        type.anchor(self).constraint(anchor)?.constant(value).identifier(identifier).active(active)
        return self.translate(false)
    }
    @discardableResult public
    func constraint(_ type: ConstraintType, value: ConstraintValue? = nil,
                    _ identifier: String? = nil, _ active: Bool = true) -> Self {
        let value = value?.value ?? 0
        
        type.anchor(self).constraint(value)?.constant(value).identifier(identifier).active(active)
        return self.translate(false)
    }
    @discardableResult public
    func constraint(_ type: ConstraintType, anchor: ConstraintAnchor?, multiplier: CGFloat,
                    value: ConstraintValue? = nil, _ identifier: String? = nil, _ active: Bool = true) -> Self {
        guard let anchor = anchor?.anchor(type) else { return self }
        guard let superview = superview else { return self }
        let value = value?.value ?? 0
        
        if type.layout {
            let layout = UILayoutGuide()
            superview.addLayoutGuide(layout)
            type.layout(layout)?.constraint(anchor)?.active(true)
            type.dimension(layout)?.constraint(type.dimension(superview), multiplier)?.active(true)
            type.anchor(self).constraint(type.opposite(layout), multiplier)?.constant(value).identifier(identifier).active(active)
        } else {
            type.anchor(self).constraint(anchor, multiplier)?.constant(value).identifier(identifier).active(active)
        }
        return self.translate(false)
    }
    @discardableResult public
    func translate(_ bool: Bool) -> Self {
        translatesAutoresizingMaskIntoConstraints = bool
        return self
    }
    private var name: String { String(describing: type(of: self) ) }
}

extension UIView {
    @discardableResult public
    func top(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.top, anchor: anchor, value: value, id ?? name+".top")
    }
    @discardableResult public
    func bottom(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.bottom, anchor: anchor, value: value, id ?? name+".bottom")
    }
    @discardableResult public
    func left(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.left, anchor: anchor, value: value, id ?? name+".left")
    }
    @discardableResult public
    func right(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.right, anchor: anchor, value: value, id ?? name+".right")
    }
    @discardableResult public
    func leading(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.leading, anchor: anchor, value: value, id ?? name+".leading")
    }
    @discardableResult public
    func trailing(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.trailing, anchor: anchor, value: value, id ?? name+".trailing")
    }
    @discardableResult public
    func width(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.width, value: value, id ?? name+".width")
    }
    @discardableResult public
    func height(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.height, value: value, id ?? name+".height")
    }
    @discardableResult public
    func width(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.width, anchor: anchor, value: value, id ?? name+".width")
    }
    @discardableResult public
    func height(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.height, anchor: anchor, value: value, id ?? name+".height")
    }
    @discardableResult public
    func x(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.x, anchor: anchor, value: value, id ?? name+".x")
    }
    @discardableResult public
    func y(_ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.y, anchor: anchor, value: value, id ?? name+".y")
    }
    
    
    @discardableResult public
    func top(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.top, anchor: superview, value: value, id ?? name+".top")
    }
    @discardableResult public
    func bottom(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.bottom, anchor: superview, value: value, id ?? name+".bottom")
    }
    @discardableResult public
    func left(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.left, anchor: superview, value: value, id ?? name+".left")
    }
    @discardableResult public
    func right(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.right, anchor: superview, value: value, id ?? name+".right")
    }
    @discardableResult public
    func leading(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.leading, anchor: superview, value: value, id ?? name+".leading")
    }
    @discardableResult public
    func trailing(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.trailing, anchor: superview, value: value, id ?? name+".trailing")
    }
    @discardableResult public
    func x(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.x, anchor: superview, value: value, id ?? name+".x")
    }
    @discardableResult public
    func y(_ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.y, anchor: superview, value: value, id ?? name+".y")
    }
    
    
    @discardableResult public
    func top(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.top, anchor: anchor, multiplier: p, value: value, id ?? name+".top")
    }
    @discardableResult public
    func bottom(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.bottom, anchor: anchor, multiplier: p, value: value, id ?? name+".bottom")
    }
    @discardableResult public
    func left(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.left, anchor: anchor, multiplier: p, value: value, id ?? name+".left")
    }
    @discardableResult public
    func right(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.right, anchor: anchor, multiplier: p, value: value, id ?? name+".right")
    }
    @discardableResult public
    func leading(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.leading, anchor: anchor, multiplier: p, value: value, id ?? name+".leading")
    }
    @discardableResult public
    func trailing(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.trailing, anchor: anchor, multiplier: p, value: value, id ?? name+".trailing")
    }
    @discardableResult public
    func width(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.width, anchor: anchor, multiplier: p, value: value, id ?? name+".width")
    }
    @discardableResult public
    func height(p: CGFloat, _ anchor: ConstraintAnchor?, _ value: ConstraintValue? = nil, id: String? = nil) -> Self {
        constraint(.height, anchor: anchor, multiplier: p, value: value, id ?? name+".height")
    }
    
    @discardableResult public
    func top(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.top, anchor: superview, multiplier: p, value: value, name+".top")
    }
    @discardableResult public
    func bottom(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.bottom, anchor: superview, multiplier: p, value: value, name+".bottom")
    }
    @discardableResult public
    func left(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.left, anchor: superview, multiplier: p, value: value, name+".left")
    }
    @discardableResult public
    func right(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.right, anchor: superview, multiplier: p, value: value, name+".right")
    }
    @discardableResult public
    func leading(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.leading, anchor: superview, multiplier: p, value: value, name+".leading")
    }
    @discardableResult public
    func trailing(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.trailing, anchor: superview, multiplier: p, value: value, name+".trailing")
    }
    @discardableResult public
    func width(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.width, anchor: superview, multiplier: p, value: value, name+".width")
    }
    @discardableResult public
    func height(p: CGFloat, _ value: ConstraintValue? = nil) -> Self {
        constraint(.height, anchor: superview, multiplier: p, value: value, name+".height")
    }
}

extension UIView {
    public var safeXAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.centerXAnchor }
        return centerXAnchor
    }
    public var safeYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.centerYAnchor }
        return centerYAnchor
    }
    public var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.topAnchor }
        return topAnchor
    }
    public var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.bottomAnchor }
        return bottomAnchor
    }
    public var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.leftAnchor }
        return leftAnchor
    }
    public var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.rightAnchor }
        return rightAnchor
    }
    public var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.leadingAnchor }
        return leadingAnchor
    }
    public var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.trailingAnchor }
        return trailingAnchor
    }
    public var safeWidthAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.widthAnchor }
        return widthAnchor
    }
    public var safeHeightAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) { return safeAreaLayoutGuide.heightAnchor }
        return heightAnchor
    }
}

extension NSLayoutConstraint {
    @discardableResult public
    func identifier(_ string: String?) -> Self {
        identifier = string
        return self
    }
    @discardableResult public
    func active(_ bool: Bool) -> Self {
        isActive = bool
        return self
    }
    @discardableResult public
    func constant(_ value: CGFloat) -> Self {
        constant = value
        return self
    }
}
