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
    
    private lazy var circles: [GappedCircle] = colors.map { [unowned self] color in
        let g = GappedCircle(circleColor: color)
        g.onClick = { self.colorSelected(color) }
        return g
    }
    private lazy var circlesStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: circles)
        stackView.spacing = 15
        return stackView
    }()
    private lazy var whiteContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layout(circlesStack).edges(top: 20, left: 20, bottom: 20, right: 20)
        return container
    }()
    private lazy var onClickBackground = OnClickControl(
        onClick: { [unowned self] in
            if !$0 {
                self.dismiss(animated: true, completion: nil)
            }
        })
    
    private let sourceViewFrame: CGRect
    
    init(viewSource: UIView) {
        sourceViewFrame = viewSource.convert(viewSource.bounds, to: nil)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hex("#F6F6F3").withAlphaComponent(0.8)
        setupViews()
    }
    
    @objc func clickedd() {
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        view.layout(onClickBackground).edges()
        view.layout(whiteContainer).leading(sourceViewFrame.origin.x - sourceViewFrame.width / 2).top(sourceViewFrame.origin.y - 34 + sourceViewFrame.height / 2)
        
    }
    
    func colorSelected(_ color: UIColor) {
        
    }
}
