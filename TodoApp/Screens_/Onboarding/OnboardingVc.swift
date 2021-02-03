//
//  OnboardingVc.swift
//  TodoApp
//
//  Created by sergey on 14.01.2021.
//

import Foundation
import UIKit
import Material
import VisualEffectView

class OnboardingVc: UIViewController {
    let imageView: UIImageView
    let imageViewContainer = UIView()
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
    lazy var gradientView = GradientView2(colors: gradientColors, direction: .horizontal)
    let visualEffectView = VisualEffectView(frame: .zero)

    private let onSkip: ((OnboardingVc) -> Void)?
    private let onClick: (OnboardingVc) -> Void
    private let shouldOnboard: Bool
    private let gradientColors: [UIColor]
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    init(imageName: String, imageWidth: CGFloat, nameText: String, detailText: String, nextStepText: String, nextStepColorState: NewCustomButton.ColorState, shouldOnboard: Bool = false, gradientColors: [UIColor], onSkip: ((OnboardingVc) -> Void)?, skipText: String?, skipColor: UIColor?, onClick: @escaping (OnboardingVc) -> Void) {
        imageView = UIImageView(image: UIImage(named: imageName)?.resize(toWidth: UIScreen.main.bounds.width * imageWidth))
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.contentMode = .center
        self.onSkip = onSkip
        self.onClick = onClick
        self.shouldOnboard = shouldOnboard
        self.gradientColors = gradientColors
        super.init(nibName: nil, bundle: nil)
        button.setTitle(nextStepText, for: .normal)
        skipButton.setTitle(skipText, for: .normal)
        skipButton.setTitleColor(skipColor, for: .normal)
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: Constants.animationDefaultDuration * 4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn) {
            self.imageView.transform = .identity
        } completion: { _ in
        }
        self.gradientView.animateLocations()

        UIView.animate(withDuration: Constants.animationDefaultDuration * 4, delay: 0.0, options: [.autoreverse, .repeat, .curveEaseIn]) {
            self.visualEffectView.blurRadius = 0.2 * UIScreen.main.bounds.width
        }

    }
    private func setupViews() {
        imageView.transform = .init(scaleX: 0.5, y: 0.5)
        view.backgroundColor = UIColor(named: "TABackground")
        visualEffectView.colorTint = .clear
        visualEffectView.blurRadius = 0.12 * UIScreen.main.bounds.width
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(gradientView)
        view.addSubview(visualEffectView)
        centerView.layout(imageViewContainer).leading().trailing().top()
        imageViewContainer.layout(imageView).edges()
        centerView.layout(nameLabel).leading().trailing().top(imageView.anchor.bottom, 0.06696 * UIScreen.main.bounds.height)
        centerView.layout(detailLabel).leading().trailing().top(nameLabel.anchor.bottom, 0.02455 * UIScreen.main.bounds.height).bottom()
        view.layout(centerView).centerY(-0.095982 * UIScreen.main.bounds.height).width(UIScreen.main.bounds.width * 0.8225).centerX()
        view.layout(skipButton).bottom(Constants.vcMinBottomPadding + 10).leading(74).trailing(74)
        view.layout(button).height(60).bottom(skipButton.anchor.top, UIScreen.main.bounds.height * 0.03906).centerX().width(UIScreen.main.bounds.width * 0.7922).top(centerView.anchor.bottom, 0.052455 * UIScreen.main.bounds.height) { _, _ in .greaterThanOrEqual }
        if onSkip == nil {
            skipButton.isHidden = true
        }
        view.layout(gradientView).center(imageViewContainer.anchor.center).width(imageViewContainer.anchor.width).multiply(0.9).height(imageViewContainer.anchor.width).multiply(0.9)
        view.layout(visualEffectView).edges()
    }
    
}

extension OnboardingVc {
    static func getOnboardingNavigation(onSkip: @escaping () -> Void, onPremiumVc: @escaping () -> Void) -> UINavigationController {
        let sixthVc = OnboardingVc(imageName: "stepsix",
                                   imageWidth: 0.84,
                                   nameText: "Add your projects and work directly with them.",
                                   detailText: "Put icons on projects, change colors, and do whatever you want.",
                                   nextStepText: "Only $4,99",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   gradientColors: [UIColor.hex("#C8D8FF"), UIColor.hex("#FFB1F2"), UIColor.hex("#FFCCC9"), UIColor.hex("#FFE5BD")],
                                   onSkip: { vc in
                                    onSkip()
                                   },
                                   skipText: "Continue without purchasing",
                                   skipColor: UIColor.hex("#A4A4A4"),
                                   onClick: { vc in
                                    onPremiumVc()
                                   })

        let fifthVc = OnboardingVc(imageName: "stepfive",
                                   imageWidth: 0.35,
                                   nameText: "Tags will help you label different thoughts.",
                                   detailText: "Put up the tags, and solve your problems, as well as search by tag will help.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   gradientColors: [UIColor.hex("#CEFFC1"), UIColor.hex("#D2FFD5")],
                                   onSkip: { vc in
                                    vc.navigationController?.pushViewController(sixthVc, animated: true)
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(sixthVc, animated: true)
                                   })

        let fourthVc = OnboardingVc(imageName: "stepfour",
                                    imageWidth: 0.34,
                                   nameText: "Plan ahead, and write down everything.",
                                   detailText: "A calendar will solve all the problems of how to arrange everything for years to come.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   gradientColors: [UIColor.hex("#CADAFF"), UIColor.hex("#B9CEFF")],
                                   onSkip: { vc in
                                    vc.navigationController?.pushViewController(sixthVc, animated: true)
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(fifthVc, animated: true)
                                   })

        let thirdVc = OnboardingVc(imageName: "stepthree",
                                   imageWidth: 0.81,
                                   nameText: "Priority will help you sort things out.",
                                   detailText: "Set a priority so you don't forget what's important to you.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   gradientColors: [UIColor.hex("#85A9FF"), UIColor.hex("#FFAEA9"), UIColor.hex("#FFE0B2")],
                                   onSkip: { vc in
                                    vc.navigationController?.pushViewController(sixthVc, animated: true)
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(fourthVc, animated: true)
                                   })
        let secondVc = OnboardingVc(imageName: "steptwo",
                                    imageWidth: 0.37,
                                   nameText: "See all your thoughts for today.",
                                   detailText: "In today's screen you can see all your tasks for today and make it.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   gradientColors: [UIColor.hex("#FFE9C8"), UIColor.hex("#FFF9C1")],
                                   onSkip: { vc in
                                    vc.navigationController?.pushViewController(sixthVc, animated: true)
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(thirdVc, animated: true)
                                   })
        let firstVc = OnboardingVc(imageName: "stepone",
                                   imageWidth: 0.35,
                                   nameText: "Write anything you can think of",
                                   detailText: "Collect all your thoughts in the inbox so you don’t forget. You can review it later.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: .blue, normal: .hex("#447BFE")),
                                   shouldOnboard: true,
                                   gradientColors: [UIColor.hex("#D3C4FF"), UIColor.hex("#D8CBFF")],
                                   onSkip: { vc in
                                    vc.navigationController?.pushViewController(sixthVc, animated: true)
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    vc.navigationController?.pushViewController(secondVc, animated: true)
                                   })


        let nc = OnboardingNavigationController(rootViewController: firstVc)
        return nc
    }
}
