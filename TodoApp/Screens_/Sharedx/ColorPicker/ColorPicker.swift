//
//  ColorPicker.swift
//  TodoApp
//
//  Created by sergey on 29.11.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class ColorPicker: UIViewController {
    private let colors: [UIColor] = [.hex("#242424"), .hex("#447BFE"), .hex("#571CFF"), .hex("#00CE15"), .hex("#FFE600"), .hex("#EF4439"), .hex("#FF9900")]
    
    private lazy var circles: [GappedCircle] = colors.map { [weak self] color in
        guard let self = self else { return GappedCircle(circleColor: .black) }
        let g = GappedCircle(circleColor: color)
        g.configure(isSelected: color == selectedColor, animated: false)
        g.onClick = { [weak self] in self?.colorSelected(color) }
        return g
    }
    private lazy var circlesStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: circles)
        stackView.spacing = 15
        return stackView
    }()
    private lazy var whiteContainer: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor(named: "TAAltBackground")!
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layout(circlesStack).edges(top: 20, left: 20, bottom: 20, right: 20)
        return container
    }()
    private lazy var onClickBackground = OnClickControl(
        onClick: { [weak self] in
            guard let self = self else { return }
            if !$0 {
                if self.shouldDismiss != nil {
                    self.shouldDismissAnimated()
                } else {
                self.dismiss(animated: true, completion: nil)
                }
            }
        })
    private var selectedColor: UIColor
    private let sourceViewFrame: CGRect
    private let onColorSelection: (UIColor, ColorPicker) -> Void
    var shouldDismiss: (() -> Void)?
    var shouldPurposelyAnimateViewBackgroundColor: Bool = false
    init(viewSource: UIView, selectedColor: UIColor, onColorSelection: @escaping (UIColor, ColorPicker) -> Void) {
        self.selectedColor = selectedColor
        self.onColorSelection = onColorSelection
        sourceViewFrame = viewSource.convert(viewSource.bounds, to: nil)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    var isShouldDismissInternal = false
    func shouldDismissAnimated() {
        guard !isShouldDismissInternal else { return }
        isShouldDismissInternal = true
        UIView.animate(withDuration: Constants.animationDefaultDuration) {
            self.view.layer.opacity = 0
        } completion: { _ in
            self.shouldDismiss?()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TABackground")!.withAlphaComponent(0.8)
        setupViews()
        if shouldPurposelyAnimateViewBackgroundColor {
            view.layer.opacity = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldPurposelyAnimateViewBackgroundColor {
            UIView.animate(withDuration: Constants.animationDefaultDuration) {
                self.view.layer.opacity = 1
            }
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        view.layout(onClickBackground).edges()
        view.layout(whiteContainer).leading(sourceViewFrame.origin.x - sourceViewFrame.width / 2).top(sourceViewFrame.origin.y - 34 + sourceViewFrame.height / 2)
        
    }
    
    func colorSelected(_ color: UIColor) {
        circles.first(where: { $0.circleColor == selectedColor })?.configure(isSelected: false, animated: true)
        selectedColor = color
        circles.first(where: { $0.circleColor == selectedColor })?.configure(isSelected: true, animated: true)
        onColorSelection(color, self)
    }
}
