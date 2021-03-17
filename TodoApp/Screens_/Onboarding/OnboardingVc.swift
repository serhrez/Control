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
    private var viewControllers: [OnboardingVc]!
    private var currentViewController: OnboardingVc?
    private var nextViewController: OnboardingVc?
    private var backgroundView: UIView = UIView()
    private let visualEffectView = VisualEffectView(frame: .zero)
    private var gradients: [[UIColor]] = []
    private var gradientAlphas: [CGFloat] = []
    private var blackThemeGradientAlphas: [CGFloat] = []
    private var blackThemeGradients: [[UIColor]] = []
    private var gradientViews: [GradientView2] = []
    private var currentScreen: Int = -1
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = UIColor(named: "TABackground")
//        LaunchScreenManager().animateAfterLaunch(self.view)
    }
    func setOnboardingStack(viewControllers: [OnboardingVc], gradients: [[UIColor]], blackThemeGradients: [[UIColor]], gradientAlphas: [CGFloat], blackThemeGradientAlphas: [CGFloat]) {
        self.viewControllers = viewControllers.reversed()
        self.gradients = gradients
        self.blackThemeGradients = blackThemeGradients
        self.gradientAlphas = gradientAlphas
        self.blackThemeGradientAlphas = blackThemeGradientAlphas
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
        currentViewController?.animateIn()
    }
    
    func addGradient(_ index: Int, offsetIndex: Int? = nil) {
        guard index == gradients.indices.last else { return }
        let gradientView = GradientView2(colors: isDarkTheme() ? blackThemeGradients[index] : gradients[index], direction: .horizontal)
        gradientView.alpha = isDarkTheme() ? blackThemeGradientAlphas[index] : gradientAlphas[index]
        backgroundView.addSubview(gradientView)
        let yOffset: CGFloat = 0.18
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
        nextViewController.animateIn()
        UIView.animate(withDuration: Constants.animationOnboardingDuration) {
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
        view.font = Fonts.heading1
        view.numberOfLines = 2
        view.textAlignment = .center
        view.textColor = UIColor(named: "TAHeading")!
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    let detailLabel: UILabel = {
        let view = UILabel()
        view.font = Fonts.text
        view.textAlignment = .center
        view.numberOfLines = 0
        view.textColor = UIColor(named: "TASubElement")!
        view.adjustsFontSizeToFitWidth = true
        return view
    }()
    let centerView: UIView = {
        return UIView()
    }()
    
    lazy var save50Label: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor(named: "TAPremSpecial2")
        view.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        
        let label = UILabel()
        label.font = UIFont(name: "Inter-SemiBold", size: 18)
        label.text = "SAVE 50%".localizable()
        label.textColor = UIColor(named: "TAPremSpecial1")
        label.adjustsFontSizeToFitWidth = true

        view.layout(label).center().leading(0.036231884057971 * UIScreen.main.bounds.width) { _, _ in .greaterThanOrEqual }.trailing(0.036231884057971 * UIScreen.main.bounds.width) { _, _ in .lessThanOrEqual }
        
        return view
    }()
    lazy var notaSubscriptionLabel: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = UIColor.hex("#FFE600")
        view.snp.makeConstraints { make in
            make.height.equalTo(42)
        }
        let label = UILabel()
        label.font = UIFont(name: "Inter-Bold", size: 15)
        label.attributedText = "NOT A SUBSCRIPTION".localizable().at.attributed { attr in
            attr.underlineStyle(.single).foreground(color: .hex("#242424"))
        }
        label.adjustsFontSizeToFitWidth = true
        
        view.layout(label).center().leading(0.036231884057971 * UIScreen.main.bounds.width) { _, _ in .greaterThanOrEqual }.trailing(0.036231884057971 * UIScreen.main.bounds.width) { _, _ in .lessThanOrEqual }
        return view
    }()

    let button: NewCustomButton = {
        let view = NewCustomButton()
        view.layer.cornerRadius = 16
        view.stateBackgroundColor = .init(highlighted: .blue, normal: .hex("#447BFE"))
        view.titleLabel?.font = Fonts.heading2
        view.setTitleColor(UIColor(named: "TAAltBackground"), for: .normal)
        view.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        return view
    }()
    let skipButton: NewCustomButton = {
        let view = NewCustomButton()
        view.setTitleColor(.hex("#447BFE"), for: .normal)
        view.opacityState = .init(highlighted: 0.5, normal: 1)
        view.titleLabel?.font = Fonts.heading4
        view.addTarget(self, action: #selector(skipClicked), for: .touchUpInside)
        return view
    }()

    private let onSkip: ((OnboardingVc) -> Void)?
    private let onClick: (OnboardingVc) -> Void
    private let shouldOnboard: Bool
    private let isPremiumScreen: Bool
    init(imageName: String, imageWidth: CGFloat, nameText: String, detailText: String, nextStepText: String, nextStepColorState: NewCustomButton.State<UIColor>, titleColor: UIColor? = nil, titleColorSelected: UIColor? = nil, isPremiumScreen: Bool = false, shouldOnboard: Bool = false, onSkip: ((OnboardingVc) -> Void)?, skipText: String?, skipColor: UIColor?, onClick: @escaping (OnboardingVc) -> Void) {
        imageView = UIImageView(image: UIImage(named: imageName))
        imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * imageWidth).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        
        self.onSkip = onSkip
        self.isPremiumScreen = isPremiumScreen
        self.onClick = onClick
        self.shouldOnboard = shouldOnboard
        super.init(nibName: nil, bundle: nil)
        button.setTitle(nextStepText, for: .normal)
        if let titleColor = titleColor, let titleColorSelected = titleColorSelected {
            button.setTitleColor(titleColor, for: .normal)
            button.setTitleColor(titleColorSelected, for: .highlighted)
        } else {
            button.setTitleColor(.white, for: .normal)
        }
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
        let alertVc = UIAlertController(title: "Error".localizable(), message: message, preferredStyle: .alert)
        alertVc.addAction(.init(title: "OK".localizable(), style: .cancel, handler: nil))
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
    func animateIn() {
        UIView.animate(withDuration: Constants.animationOnboardingDuration * 2, delay: Constants.animationOnboardingDuration * 0.25, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseIn) {
            self.imageView.transform = .identity
        } completion: { _ in
        }
    }
    private func setupViews() {
        imageView.transform = .init(scaleX: 0.6, y: 0.6)
        centerView.layout(imageViewContainer).leading().trailing().top().height(imageViewContainer.anchor.width)
        imageViewContainer.layout(imageView).center()
        centerView.layout(nameLabel).leading().trailing().top(imageViewContainer.anchor.bottom, Constants.displayVersion2 && isPremiumScreen ? 2 : ((Constants.displayVersion2 ? 0.045 : 0.06696) * UIScreen.main.bounds.height))
        centerView.layout(detailLabel).leading().trailing().top(nameLabel.anchor.bottom, Constants.displayVersion2 && isPremiumScreen ? 2 : ((Constants.displayVersion2 ? 0.018 : 0.02455) * UIScreen.main.bounds.height)).bottom()
        view.layout(centerView).centerY(-0.095982 * UIScreen.main.bounds.height).width(UIScreen.main.bounds.width * 0.8225).centerX()
        view.layout(skipButton).bottom(UIScreen.main.bounds.height * (Constants.displayVersion2 ? 0.035 : 0.05)).leading(74).trailing(74)
        view.layout(button).height(60).bottomSafe(Constants.vcMinBottomPadding + 10 + 20 + UIScreen.main.bounds.height * 0.03906) { _, _ in .greaterThanOrEqual }.centerX().width(UIScreen.main.bounds.width * 0.7922).top(centerView.anchor.bottom, (Constants.displayVersion2 ? 0.04 : 0.052455) * UIScreen.main.bounds.height) { _, _ in .greaterThanOrEqual }
        if onSkip == nil {
            skipButton.isHidden = true
        }
        if isPremiumScreen {
            view.layout(save50Label).bottom(button.anchor.top, 6).leading(button.anchor.leading)
            view.layout(notaSubscriptionLabel).bottom(button.anchor.top, 6).leading(save50Label.anchor.trailing, 8).trailing(button.anchor.trailing)
        }
        view.bringSubviewToFront(skipButton)
    }
    
}

extension OnboardingVc {
    static func getOnboardingNavigation(onSkip: @escaping () -> Void, onPremiumVc: @escaping () -> Void) -> OnboardingVcContainer {
        let onboardingVc = OnboardingVcContainer()

        let sixthVc = OnboardingVc(imageName: "stepsix",
                                   imageWidth: Constants.displayVersion2 ? 0.8 : 0.920289855072464,
                                   nameText: "Add Your Projects And Work Directly With Them.".localizable(),
                                   detailText: "Put icons on projects, change colors, and do whatever you want.".localizable(),
                                   nextStepText: "\("Only".localizable(comment: "Only $2.99")) \(InAppManager.shared.productPrice)",
                                   nextStepColorState: .init(highlighted: UIColor.hex("#412904"), normal: .hex("#FF9900")),
                                   titleColor: UIColor.hex("#412904"),
                                   titleColorSelected: UIColor.hex("#ff9900"),
                                   isPremiumScreen: true,
                                   onSkip: { vc in
                                    onSkip()
                                   },
                                   skipText: "Continue without purchasing".localizable(),
                                   skipColor: UIColor.hex("#A4A4A4"),
                                   onClick: { vc in
                                    onPremiumVc()
                                   })

        let fifthVc = OnboardingVc(imageName: "stepfive",
                                   imageWidth: 0.49275,
                                   nameText: "Tags Help You To Label Different Thoughts.".localizable(),
                                   detailText: "Put up the tags, and solve your plans, as well as search by tag.".localizable(),
                                   nextStepText: "Next Step".localizable(),
                                   nextStepColorState: .init(highlighted: UIColor.hex("#571CFF").withAlphaComponent(0.5), normal: .hex("#571CFF")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip".localizable(),
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })

        let fourthVc = OnboardingVc(imageName: "stepfour",
                                    imageWidth: 0.444,
                                   nameText: "Plan Ahead, And Note Everything.".localizable(),
                                   detailText: "The calendar will solve all the Plans of how to arrange everything even for the upcoming years.".localizable(),
                                   nextStepText: "Next Step".localizable(),
                                   nextStepColorState: .init(highlighted: UIColor.hex("#447bfe").withAlphaComponent(0.5), normal: .hex("#447bfe")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip".localizable(),
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })

        let thirdVc = OnboardingVc(imageName: "stepthree",
                                   imageWidth: 0.686,
                                   nameText: "Prioritization Helps You To Sort Things Out.".localizable(),
                                   detailText: "Set a prior task, so you don't forget what's important to you.".localizable(),
                                   nextStepText: "Next Step".localizable(),
                                   nextStepColorState: .init(highlighted: UIColor.hex("#00ce15").withAlphaComponent(0.5), normal: .hex("#00ce15")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip".localizable(),
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })
        let secondVc = OnboardingVc(imageName: "steptwo",
                                    imageWidth: 0.53,
                                   nameText: "See All Your Plans For Today.".localizable(),
                                   detailText: "In today's screen you can see all your tasks for today and fulfill them.".localizable(),
                                   nextStepText: "Next Step".localizable(),
                                   nextStepColorState: .init(highlighted: UIColor.hex("#571cff").withAlphaComponent(0.5), normal: .hex("#571cff")),
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip".localizable(),
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })
        let firstVc = OnboardingVc(imageName: "stepone",
                                   imageWidth: 0.46,
                                   nameText: "Write Something You Can Think Of.".localizable(),
                                   detailText: "Collect all your thoughts in the inbox so you don’t forget. You can review it later.".localizable(),
                                   nextStepText: "Next Step".localizable(),
                                   nextStepColorState: .init(highlighted: UIColor.hex("#447bfe").withAlphaComponent(0.5), normal: .hex("#447BFE")),
                                   shouldOnboard: true,
                                   onSkip: { vc in
                                    onboardingVc.toLast()
                                   },
                                   skipText: "Skip".localizable(),
                                   skipColor: UIColor.hex("#447BFE"),
                                   onClick: { vc in
                                    onboardingVc.toNext()
                                   })


        onboardingVc.setOnboardingStack(viewControllers: [firstVc, secondVc, thirdVc, fourthVc, fifthVc, sixthVc], gradients: [
            [UIColor.hex("#E1D7FF"), UIColor.hex("#E3EEFF")],
            [UIColor.hex("#FFF3E1"), UIColor.hex("#FFFCE3")],
            [UIColor.hex("#C5D6FF"), UIColor.hex("#FFD0CD"), UIColor.hex("#FFF0DA")],
            [UIColor.hex("#DEE8FF"), UIColor.hex("#FEDCFF")],
            [UIColor.hex("#E9FFE3"), UIColor.hex("#E0FFED")],
            [UIColor.hex("#B7CCFF"), UIColor.hex("#FFAFF1"), UIColor.hex("#FFBDB9"), UIColor.hex("#FFE5BD"), UIColor.hex("#FFDEAC")]
        ], blackThemeGradients: [
            [UIColor.hex("#4200FF"), UIColor.hex("#00A3FF")],
            [UIColor.hex("#FFE500"), UIColor.hex("#FBA21D")],
            [UIColor.hex("#001AFF"), UIColor.hex("#FF0F00"), UIColor.hex("#FF9900")],
            [UIColor.hex("#3975FF"), UIColor.hex("#004BFF")],
            [UIColor.hex("#33FF00"), UIColor.hex("#00FF0D")],
            [UIColor.hex("#004CFF"), UIColor.hex("#FF00D4"), UIColor.hex("#FF0F00"), UIColor.hex("#FFE600")]
        ], gradientAlphas: [
            1, 1, 1, 1, 1, 1
        ], blackThemeGradientAlphas: [
            0.1, 0.1, 0.1, 0.1, 0.1, 0.4
        ]) // 6 steps
        return onboardingVc
    }
}
