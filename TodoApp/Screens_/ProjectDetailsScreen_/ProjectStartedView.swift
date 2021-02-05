//
//  ProjectStartedView.swift
//  TodoApp
//
//  Created by sergey on 21.12.2020.
//

import Foundation
import UIKit
import Material
import AttributedLib

class ProjectStartedView: UIView {
    private let mode: Mode
    init(mode: Mode) {
        self.mode = mode
        super.init(frame: .zero)
        setupView()
    }
    func configure(tintColor: UIColor? = nil, mode: Mode? = nil) {
        if let tintColor = tintColor {
            imageView.tintColor = tintColor
        }
        if let mode = mode {
            var smallTitleWithPlusAlpha: CGFloat = 0
            var detailTitleAlpha: CGFloat = 0
            var largeTitleNumberOfLines: Int = 2
            switch mode {
            case .noPriorities:
                largeTitle.text = "There are no priorities right now"
                detailTitle.text = "All of your assignments are displayed here"
                detailTitleAlpha = 1
            case .freeDay:
                largeTitle.text = "You have a free day"
                detailTitle.text = "All of your assignments are displayed here"
                detailTitleAlpha = 1
                largeTitleNumberOfLines = 1
            case .projectEmpty:
                largeTitle.text = "That's a good one, you're doing great!"
                smallTitleWithPlusAlpha = 1
            case .started:
                smallTitleWithPlusAlpha = 1
            case .noCalendarPlanned:
                detailTitleAlpha = 1
                largeTitle.text = "There are no planned tasks"
                detailTitle.text = "Planned tasks will be shown here"
            }
            smallTitleWithPlus.alpha = smallTitleWithPlusAlpha
            detailTitle.alpha = detailTitleAlpha
            largeTitle.numberOfLines = largeTitleNumberOfLines
        }
    }
    
    private func setupView() {
        imageView.tintColor = UIColor(named: "TAHeading")
        imageView.contentMode = .scaleAspectFit
        layout(imageView).leading(27).trailing(27).top().width(imageView.anchor.height).multiply(1.1436)
        layout(largeTitle).leading().trailing().top(imageView.anchor.bottom, 25.35)
        layout(smallTitleWithPlus).centerX().top(largeTitle.anchor.bottom, 12).bottom() { _, _ in .lessThanOrEqual }
        layout(detailTitle).centerX().top(largeTitle.anchor.bottom, 12).bottom() { _, _ in .lessThanOrEqual }
        configure(mode: mode)
    }
    private let imageView = UIImageView(image: UIImage(named: "startedmessypath")?.withRenderingMode(.alwaysTemplate))

    let largeTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(named: "TAHeading")!
        label.text = "Well done, you started a new project!"
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    lazy var detailTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "TAHeading")!
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    lazy var smallTitleWithPlus: UIView = {
        let view = UIView()
        view.layout(smallTitleLeading).leading().top().bottom()
        view.layout(smallTitleTrailing).trailing().top().bottom()
        view.layout(plusImage).leading(smallTitleLeading.anchor.trailing, 4).trailing(smallTitleTrailing.anchor.leading, 4)
        plusImage.bottomAnchor.constraint(equalTo: smallTitleLeading.firstBaselineAnchor, constant: 1).isActive = true
        return view
    }()
    
    let smallTitleLeading: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "TAHeading")!
        label.text = "Tap the"
        return label
    }()
    let smallTitleTrailing: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(named: "TAHeading")!
        label.text = "button to write it down!"
        return label
    }()
    let plusImage: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
        view.heightAnchor.constraint(equalToConstant: 14).isActive = true
        view.backgroundColor = .hex("#447BFE")
        view.layer.cornerRadius = 7
        let plusPath = UIImageView(image: UIImage(named: "check")?.resize(toWidth: 8)?.withRenderingMode(.alwaysTemplate))
        plusPath.tintColor = UIColor.white
        view.layout(plusPath).center()
        return view
    }()
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProjectStartedView {
    enum Mode {
        case started
        case freeDay
        case noPriorities
        case projectEmpty
        case noCalendarPlanned
    }
}
