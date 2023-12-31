//
//  PopuptodoAction.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import PopMenu
import Material

/// The default PopMenu action class.
public class PopuptodoAction: NSObject, PopMenuAction {
    
    public static var iconLeftPadding: CGFloat = 0
    
    /// Title of action.
    public let title: String?
    
    /// Icon of action.
    public let image: UIImage?
    
    /// Image rendering option.
    public var imageRenderingMode: UIImage.RenderingMode = .alwaysTemplate
    
    /// Renderred view of action.
    public let view: UIView
    
    /// Color of action.
    public let color: PopMenu.Color?
    
    /// Handler of action when selected.
    public let didSelect: PopMenuActionHandler?
    
    /// Icon sizing.
    public var iconWidthHeight: CGFloat = 21
    
    public var iconLeftPadding: CGFloat = 19
        
    public var iconToTextOffset: CGFloat = 14
    
    private let overlayView = UIView()
    
    // MARK: - Computed Properties
    
    /// Text color of the label.
    public var tintColor: PopMenu.Color {
        get {
            return titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }
    
    var imageTintColor: UIColor {
        get {
            return iconImageView.tintColor
        }
        set {
            iconImageView.tintColor = newValue
        }
    }
    
    /// Font for the label.
    public var font: UIFont {
        get {
            return titleLabel.font
        }
        set {
            titleLabel.font = newValue
        }
    }
    
    /// Rounded corner radius for action view.
    public var cornerRadius: CGFloat {
        get {
            return view.layer.cornerRadius
        }
        set {
            view.layer.cornerRadius = newValue
        }
    }
    
    /// Inidcates if the action is being highlighted.
    public var highlighted: Bool = false {
        didSet {
            guard highlighted != oldValue else { return }
            
            highlightActionView(highlighted)
        }
    }
    public var isSelectable = true
    
    /// Background color for highlighted state.
    public var overlayColor: PopMenu.Color = UIColor(named: "TAAltBackground")!

    // MARK: - Subviews
    
    /// Title label view instance.
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.text = title
        
        return label
    }()
    
    /// Icon image view instance.
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private lazy var iconImageViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Constants
    
    public static let textLeftPadding: CGFloat = 25
    
    // MARK: - Initializer
    
    /// Initializer.
    public init(title: String? = nil, image: UIImage? = nil, color: PopMenu.Color? = nil, isSelectable: Bool = true, didSelect: PopMenuActionHandler? = nil) {
        self.title = title
        self.image = image
        self.color = color
        self.isSelectable = isSelectable
        self.didSelect = didSelect
        
        view = UIView()
        overlayView.backgroundColor = .clear
    }
    
    @objc public func setOverlayViewCornerRadius(_ cornerRadius: CGFloat) {
        overlayView.layer.cornerRadius = cornerRadius
    }
    
    /// Setup necessary views.
    fileprivate func configureViews() {
        var hasImage = false

        if let _ = image {
            hasImage = true
            view.layout(iconImageViewContainer).height(iconWidthHeight).width(iconWidthHeight).leading(view.anchor.leading, iconLeftPadding).centerY(view.anchor.centerY)
            iconImageViewContainer.layout(iconImageView).edges()
        }
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: hasImage ? iconLeftPadding + iconWidthHeight + iconToTextOffset : iconLeftPadding),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// Load and configure the action view.
    public func renderActionView() {
//        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        
        configureViews()
    }
    
    /// Highlight the view when panned on top,
    /// unhighlight the view when pan gesture left.
    public func highlightActionView(_ highlight: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.26, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 9, options: self.highlighted ? UIView.AnimationOptions.curveEaseIn : UIView.AnimationOptions.curveEaseOut, animations: {
                self.overlayView.backgroundColor = self.highlighted ? self.overlayColor.withAlphaComponent(0.25) : .clear
            }, completion: nil)
        }
    }
    
    /// When the action is selected.
    public func actionSelected(animated: Bool) {
        // Trigger handler.
        didSelect?(self)
        
        // Animate selection
        guard animated else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.175, animations: {
                self.overlayView.backgroundColor = self.overlayColor.withAlphaComponent(0.18)
            }, completion: { _ in
                UIView.animate(withDuration: 0.175, animations: {
                    self.overlayView.backgroundColor = .clear
                })
            })
        }
    }
    
}


