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

class OnboardingVcContainer: UIViewController {
    private var viewControllers: [UIViewController]!
    private var currentViewController: UIViewController?
    private var nextViewController: UIViewController?
    private var backgroundView: UIView = UIView()
    private let visualEffectView = VisualEffectView(frame: .zero)
    private var gradients: [[UIColor]] = []
    private var blackThemeGradients: [[UIColor]] = []
    private var gradientViews: [GradientView2] = []
    private var currentScreen: Int = -1
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(named: "TABackground")
//        LaunchScreenManager().animateAfterLaunch(self.view)
    }
    func setOnboardingStack(viewControllers: [UIViewController], gradients: [[UIColor]], blackThemeGradients: [[UIColor]]) {
        self.viewControllers = viewControllers.reversed()
        self.gradients = gradients
        self.blackThemeGradients = blackThemeGradients
        self.view.addSubview(backgroundView)
        self.view.addSubview(visualEffectView)
        visualEffectView.colorTint = .clear
        visualEffectView.blurRadius = 0.2 * UIScreen.main.bounds.width
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width * CGFloat(viewControllers.count), height: UIScreen.main.bounds.height)
        visualEffectView.frame = UIScreen.main.bounds
        let topVc = self.viewControllers.popLast()!
        currentViewController = topVc
        self.addChild(topVc)
        self.view.addSubview(topVc.view)
        self.nextViewController = self.viewControllers.popLast()
        addGradient(0)
        addNextToRight()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addGradient(_ index: Int, offsetIndex: Int? = nil) {
        let gradientView = GradientView2(colors: isDarkTheme() ? blackThemeGradients[index] : gradients[index], direction: .horizontal)
        gradientView.alpha = isDarkTheme() ? 0.1 : 0.8
        backgroundView.addSubview(gradientView)
        let yOffset: CGFloat = Constants.displayVersion2 ? 0.13 : 0.18
        gradientView.frame = .init(x: CGFloat(offsetIndex ?? index) * UIScreen.main.bounds.width + 0.25 * UIScreen.main.bounds.width, y: yOffset * UIScreen.main.bounds.height, width: 0.50 * UIScreen.main.bounds.width, height: 0.50 * UIScreen.main.bounds.width)
        gradientView.animateLocations()
        gradientViews.append(gradientView)
        if gradientViews.count > 2 && offsetIndex == nil {
            gradientViews.removeFirst().removeFromSuperview()
        }
    }
    
    func addNextToRight(gradientInt: Int? = nil, offsetIndex: Int? = nil) {
        guard let currentViewController = currentViewController else { return }
        guard let nextViewController = nextViewController else { return }
        let nextVcFrame = CGRect(x: currentViewController.view.frame.origin.x + UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        nextViewController.view.frame = nextVcFrame
        self.addChildPresent(nextViewController)
        currentScreen += 1
        addGradient(gradientInt ?? currentScreen + 1, offsetIndex: offsetIndex)
    }
    
    func toNext(addNextToRight: Bool = true) {
        guard let currentViewController = currentViewController else { return }
        guard let nextViewController = nextViewController else { return }
        UIView.animate(withDuration: 0.5) {
            nextViewController.view.frame = CGRect(x: nextViewController.view.frame.origin.x - UIScreen.main.bounds.width, y: nextViewController.view.frame.origin.y, width: nextViewController.view.frame.width, height: nextViewController.view.frame.height)
            currentViewController.view.frame = .init(origin: CGPoint(x: -self.view.bounds.size.width, y: 0), size: self.view.bounds.size)
            self.backgroundView.frame = .init(x: self.backgroundView.frame.origin.x - UIScreen.main.bounds.width, y: self.backgroundView.frame.origin.y, width: self.backgroundView.frame.width, height: self.backgroundView.frame.height)
        } completion: { _ in
            self.currentViewController?.addChildDismiss()
            self.currentViewController = nextViewController
            self.nextViewController = self.viewControllers.popLast()
            if addNextToRight {
                self.addNextToRight()
            }
        }
    }
    
    func toLast() {
        guard let currentViewController = currentViewController else { return }
        guard let last = viewControllers.first else { return }
        nextViewController = last
        addNextToRight(gradientInt: gradients.count - 1, offsetIndex: currentScreen + 1)
        toNext(addNextToRight: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

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

    private let onSkip: ((OnboardingVc) -> Void)?
    private let onClick: (OnboardingVc) -> Void
    private let shouldOnboard: Bool
    private let isPremiumScreen: Bool
    init(imageName: String, imageWidth: CGFloat, nameText: String, detailText: String, nextStepText: String, nextStepColorState: NewCustomButton.ColorState, isPremiumScreen: Bool = false, shouldOnboard: Bool = false, onSkip: ((OnboardingVc) -> Void)?, skipText: String?, skipColor: UIColor?, onClick: @escaping (OnboardingVc) -> Void) {
        imageView = UIImageView(image: UIImage(named: imageName)?.resize(toWidth: UIScreen.main.bounds.width * imageWidth))
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.contentMode = .center
        self.onSkip = onSkip
        self.isPremiumScreen = isPremiumScreen
        self.onClick = onClick
        self.shouldOnboard = shouldOnboard
        super.init(nibName: nil, bundle: nil)
        button.setTitle(nextStepText, for: .normal)
        button.setTitleColor(.white, for: .normal)
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
        if isPremiumScreen {
            InAppManager.shared.purchaseProduct { [weak self] error in
                if let error = error {
                    self?.handle(error)
                } else {
                    print("Success buy")
                    guard let self = self else { return }
                    self.onClick(self)
                }
            }
        } else {
            onClick(self)
        }
    }
    
    private func handle(_ error: InAppError) {
        let message = error.message
        let alertVc = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVc.addAction(.init(title: "OK", style: .cancel, handler: nil))
        present(alertVc, animated: true, completion: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        applySharedNavigationBarAppearance(addBackButton: false, popGesture: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        setupViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: Constants.animationDefaultDuration * 4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn) {
            self.imageView.transform = .identity
        } completion: { _ in
        }
    }
    private func setupViews() {
        imageView.transform = .init(scaleX: 0.5, y: 0.5)
        centerView.layout(imageViewContainer).leading().trailing().top()
        imageViewContainer.layout(imageView).edges()
        centerView.layout(nameLabel).leading().trailing().top(imageViewContainer.anchor.bottom, 0.06696 * UIScreen.main.bounds.height)
        centerView.layout(detailLabel).leading().trailing().top(nameLabel.anchor.bottom, 0.02455 * UIScreen.main.bounds.height).bottom()
        view.layout(centerView).centerY(-0.095982 * UIScreen.main.bounds.height).width(UIScreen.main.bounds.width * 0.8225).centerX()
        view.layout(skipButton).bottom(UIScreen.main.bounds.height * (Constants.displayVersion2 ? 0.035 : 0.05)).leading(74).trailing(74)
        view.layout(button).height(60).bottom(Constants.vcMinBottomPadding + 10 + 20 + UIScreen.main.bounds.height * 0.03906) { _, _ in .greaterThanOrEqual }.centerX().width(UIScreen.main.bounds.width * 0.7922).top(centerView.anchor.bottom, (Constants.displayVersion2 ? 0.04 : 0.052455) * UIScreen.main.bounds.height) { _, _ in .greaterThanOrEqual }
        if onSkip == nil {
            skipButton.isHidden = true
        }
        view.bringSubviewToFront(skipButton)
    }
    
}

extension OnboardingVc {
    static func getOnboardingNavigation(onSkip: @escaping () -> Void, onPremiumVc: @escaping () -> Void) -> OnboardingVcContainer {
        let onboardingVc = OnboardingVcContainer()

        let sixthVc = OnboardingVc(imageName: "stepsix",
                                   imageWidth: 0.84,
                                   nameText: "Add Your Projects And Work Directly With Them.",
                                   detailText: "Put icons on projects, change colors, and do whatever you want.",
                                   nextStepText: "Only \(InAppManager.shared.productPrice)",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#00CE15").withAlphaComponent(0.5), normal: .hex("#00CE15")),
                                   isPremiumScreen: true,
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
                                   nameText: "Tags Help You To Label Different Thoughts.",
                                   detailText: "Put up the tags, and solve your plans, as well as search by tag.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#571CFF").withAlphaComponent(0.5), normal: .hex("#571CFF")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })

        let fourthVc = OnboardingVc(imageName: "stepfour",
                                    imageWidth: 0.34,
                                   nameText: "Plan Ahead, And Note Everything.",
                                   detailText: "The calendar will solve all the Plans of how to arrange everything even for the upcoming years.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#447bfe").withAlphaComponent(0.5), normal: .hex("#447bfe")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })

        let thirdVc = OnboardingVc(imageName: "stepthree",
                                   imageWidth: 0.81,
                                   nameText: "Prioritization Helps You To Sort Things Out.",
                                   detailText: "Set a prior task, so you don't forget what's important to you.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#00ce15").withAlphaComponent(0.5), normal: .hex("#00ce15")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })
        let secondVc = OnboardingVc(imageName: "steptwo",
                                    imageWidth: 0.37,
                                   nameText: "See All Your Plans For Today.",
                                   detailText: "In today's screen you can see all your tasks for today and fulfill them.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#571cff").withAlphaComponent(0.5), normal: .hex("#571cff")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })
        let firstVc = OnboardingVc(imageName: "stepone",
                                   imageWidth: 0.35,
                                   nameText: "Write Something You Can Think Of.",
                                   detailText: "Collect all your thoughts in the inbox so you don’t forget. You can review it later.",
                                   nextStepText: "Next Step",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#447bfe").withAlphaComponent(0.5), normal: .hex("#447BFE")),
                                   shouldOnboard: true,
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip",
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })


        onboardingVc.setOnboardingStack(viewControllers: [firstVc, secondVc, thirdVc, fourthVc, fifthVc, sixthVc], gradients: [
            [UIColor.hex("#D3C4FF"), UIColor.hex("#D8CBFF")],
            [UIColor.hex("#FFE9C8"), UIColor.hex("#FFF9C1")],
            [UIColor.hex("#85A9FF"), UIColor.hex("#FFAEA9"), UIColor.hex("#FFE0B2")],
            [UIColor.hex("#CADAFF"), UIColor.hex("#B9CEFF")],
            [UIColor.hex("#CEFFC1"), UIColor.hex("#D2FFD5")],
            [UIColor.hex("#C8D8FF"), UIColor.hex("#FFB1F2"), UIColor.hex("#FFCCC9"), UIColor.hex("#FFE5BD")]
        ], blackThemeGradients: [
            [UIColor.hex("#4200FF"), UIColor.hex("#00A3FF")],
            [UIColor.hex("#FFE500"), UIColor.hex("#FBA21D")],
            [UIColor.hex("#001AFF"), UIColor.hex("#FF0F00"), UIColor.hex("#FF9900")],
            [UIColor.hex("#3975FF"), UIColor.hex("#004BFF")],
            [UIColor.hex("#33FF00"), UIColor.hex("#00FF0D")],
            [UIColor.hex("#004CFF"), UIColor.hex("#FF00D4"), UIColor.hex("#FF0F00"), UIColor.hex("#FFE600")]
        ])
        return onboardingVc
    }
}
