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
    func configure(mode: Mode? = nil) {
        if let mode = mode {
            var smallTitleWithPlusAlpha: CGFloat = 0
            var detailTitleAlpha: CGFloat = 0
            switch mode {
            case .noPriorities:
                largeTitle.text = "There Are No Priorities Right Now.".localizable()
                detailTitle.text = "All of your assignments are displayed here.".localizable()
                detailTitleAlpha = 1
                imageView.image = UIImage(named: "placeholderred")
            case .freeDay:
                largeTitle.text = "You Have a Free Day.".localizable()
                detailTitle.text = "All of your assignments are displayed here.".localizable()
                detailTitleAlpha = 1
                imageView.image = UIImage(named: "placeholderyellow")
            case .projectEmpty:
                largeTitle.text = "Your Project is Empty.".localizable()
                smallTitleWithPlusAlpha = 1
                imageView.image = UIImage(named: "placeholderyellow")
            case .inboxEmpty:
                largeTitle.text = "Your Inbox is Empty.".localizable()
                smallTitleWithPlusAlpha = 1
                imageView.image = UIImage(named: "placeholderviolet")
            case .started:
                smallTitleWithPlusAlpha = 1
                imageView.image = UIImage(named: "placeholderyellow")
            case .noCalendarPlanned:
                detailTitleAlpha = 1
                largeTitle.text = "There Are No Planned Tasks.".localizable()
                detailTitle.text = "Planned tasks will be shown here.".localizable()
                imageView.image = UIImage(named: "placeholderyellow")
            }
            smallTitleWithPlus.alpha = smallTitleWithPlusAlpha
            detailTitle.alpha = detailTitleAlpha
            
        }
    }
    
    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        layout(imageView).leading(27).trailing(27).top().width(imageView.anchor.height).multiply(1.785714285714286)
        layout(largeTitle).leading().trailing().top(imageView.anchor.bottom, 25.35)
        layout(smallTitleWithPlus).centerX().top(largeTitle.anchor.bottom, 12).bottom() { _, _ in .lessThanOrEqual }
        layout(detailTitle).centerX().top(largeTitle.anchor.bottom, 12).bottom() { _, _ in .lessThanOrEqual }
        configure(mode: mode)
        if mode == .projectEmpty || mode == .inboxEmpty || mode == .started {
            adjustSmallTitleWithPlusFontSize()
        }
    }
    private let imageView = UIImageView(image: UIImage(named: "startedmessypath"))

    let largeTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.heading2
        label.textColor = UIColor(named: "TAHeading")!
        label.text = "Well done, you started a new project!".localizable()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    lazy var detailTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.text
        label.textColor = UIColor(named: "TASubElement")!
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
    func adjustSmallTitleWithPlusFontSize() {
        let size = smallTitleWithPlus.systemLayoutSizeFitting(.init(width: 3000, height: 100))
        if UIScreen.main.bounds.width - 50 < size.width {
            let newFont = UIFont.systemFont(ofSize: smallTitleLeading.font.pointSize - 0.7, weight: smallTitleLeading.font.getFontWeight())
            smallTitleLeading.font = newFont
            smallTitleTrailing.font = newFont
            adjustSmallTitleWithPlusFontSize()
        }
    }
    
    lazy var smallTitleLeading: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.text
        label.textColor = UIColor(named: "TASubElement")!
        label.text = "Tap the".localizable()
        return label
    }()
    lazy var smallTitleTrailing: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Fonts.text
        label.textColor = UIColor(named: "TASubElement")!
        label.text = "button to add the task!".localizable()
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
        case inboxEmpty
        case noCalendarPlanned
    }
}
