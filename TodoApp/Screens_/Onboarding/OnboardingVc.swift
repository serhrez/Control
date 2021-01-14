//
//  OnboardingVc.swift
//  TodoApp
//
//  Created by sergey on 14.01.2021.
//

import Foundation
import UIKit
import Material

class OnboardingVc: UIViewController {
    let imageView: UIImageView
    let nameLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 32, weight: .bold)
        view.numberOfLines = 2
        view.textAlignment = .center
        view.textColor = UIColor(named: "TAHeading")!
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    let detailLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = UIColor(named: "TAHeading")!
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    let centerView: UIView = {
        return UIView()
    }()
    let button: NewCustomButton = {
        let view = NewCustomButton()
        view.layer.cornerRadius = 16
        view.stateBackgroundColor = .init(highlighted: .blue, normal: .hex("#447BFE"))
        view.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        view.setTitleColor(UIColor(named: "TAAltBackground"), for: .normal)
        view.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        return view
    }()
    let skipButton: NewCustomButton = {
        let view = NewCustomButton()
        view.setTitleColor(.hex("#447BFE"), for: .normal)
        view.opacityState = .init(highlighted: 0.5, normal: 1)
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.addTarget(self, action: #selector(skipClicked), for: .touchUpInside)
        return view
    }()
    private let onSkip: ((OnboardingVc) -> Void)?
    private let onClick: (OnboardingVc) -> Void
    private let shouldOnboard: Bool
    init(imageName: String, imageMultiplier: CGFloat, nameText: String, detailText: String, nextStepText: String, nextStepColorState: NewCustomButton.ColorState, shouldOnboard: Bool = false, onSkip: ((OnboardingVc) -> Void)?, onClick: @escaping (OnboardingVc) -> Void) {
        imageView = UIImageView(image: UIImage(named: imageName))
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageMultiplier).isActive = true
        self.onSkip = onSkip
        self.onClick = onClick
        self.shouldOnboard = shouldOnboard
        super.init(nibName: nil, bundle: nil)
        button.setTitle(nextStepText, for: .normal)
        skipButton.setTitle("Skip", for: .normal)
        nameLabel.text = nameText
        detailLabel.text = detailText
        button.stateBackgroundColor = nextStepColorState
    }
    
    @objc func skipClicked() {
        onSkip?(self)
    }
    
    @objc func buttonClicked() {
        onClick(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        applySharedNavigationBarAppearance(addBackButton: false, popGesture: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        setupViews()
        if shouldOnboard {
            LaunchScreenManager().animateAfterLaunch(self.view)
        }
    }
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        centerView.layout(imageView).leading().trailing().top()
        centerView.layout(nameLabel).leading().trailing().top(imageView.anchor.bottom, 0.06696 * UIScreen.main.bounds.height)
        centerView.layout(detailLabel).leading().trailing().top(nameLabel.anchor.bottom, 0.02455 * UIScreen.main.bounds.height).bottom()
        view.layout(centerView).centerY(-0.095982 * UIScreen.main.bounds.height).width(UIScreen.main.bounds.width * 0.8225).centerX()
        view.layout(skipButton).bottom(Constants.vcMinBottomPadding + 10).leading(74).trailing(74)
        view.layout(button).height(60).bottom(skipButton.anchor.top, UIScreen.main.bounds.height * 0.03906).centerX().width(UIScreen.main.bounds.width * 0.7922).top(centerView.anchor.bottom, 0.052455 * UIScreen.main.bounds.height) { _, _ in .greaterThanOrEqual }
        if onSkip == nil {
            skipButton.isHidden = true
        }
    }
}

extension OnboardingVc {
    static func getOnboardingNavigation(onEnd: @escaping () -> Void) -> UINavigationController {
        let thirdVc = OnboardingVc(imageName: "premiumimage",
                                   imageMultiplier: 1.23,
                                   nameText: "Well done, you started a new project!",
                                   detailText: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   onSkip: nil,
                                   onClick: { vc in
                                    onEnd()
                                   })
        let secondVc = OnboardingVc(imageName: "premiumimage",
                                   imageMultiplier: 1.23,
                                   nameText: "Well done, you started a new project!",
                                   detailText: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   onSkip: { vc in
                                    onEnd()
                                   },
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(thirdVc, animated: true)
                                   })
        let firstVc = OnboardingVc(imageName: "premiumimage",
                                   imageMultiplier: 1.23,
                                   nameText: "Well done, you started a new project!",
                                   detailText: "Plan! - Create app for iOs and Testing app for iPadOs, MacOs send to server.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   shouldOnboard: true,
                                   onSkip: { vc in
                                    onEnd()
                                   },
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(secondVc, animated: true)
                                   })


        let nc = OnboardingNavigationController(rootViewController: firstVc)
        return nc
    }
}
