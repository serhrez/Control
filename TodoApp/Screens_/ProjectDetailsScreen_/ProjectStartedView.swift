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
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    private func setupView() {
        let imageView = UIImageView(image: UIImage(named: "startedmessypath"))
        layout(imageView).leading(27).trailing(27).top()
        layout(largeTitle).leading().trailing().top(imageView.anchor.bottom, 25.35)
        layout(smallTitle).centerX().top(largeTitle.anchor.bottom, 12).bottom()
    }
    let largeTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .hex("#242424")
        label.text = "Well done, you started a new project!"
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    lazy var smallTitle: UIView = {
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
        label.textColor = .hex("#242424")
        label.text = "Tap the"
        return label
    }()
    let smallTitleTrailing: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .hex("#242424")
        label.text = "button to write it down!"
        return label
    }()
    let plusImage: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: 14).isActive = true
        view.heightAnchor.constraint(equalToConstant: 14).isActive = true
        view.backgroundColor = .hex("#447BFE")
        view.layer.cornerRadius = 7
        let plusPath = UIImageView(image: UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate))
        plusPath.tintColor = .hex("#FFFFFF")
        view.layout(plusPath).edges(top: 3, left: 3, bottom: 3, right: 3)
        return view
    }()
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
