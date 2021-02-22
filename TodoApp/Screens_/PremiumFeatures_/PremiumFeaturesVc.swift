//
//  PremiumFeaturesVc.swift
//  TodoApp
//
//  Created by sergey on 11.01.2021.
//

import Foundation
import UIKit
import Material
import AttributedLib
import SwiftyDrop
import Haptica
import VisualEffectView

class PremiumFeaturesVc: UIViewController {
    private let visualEffectView: VisualEffectView = {
        let view = VisualEffectView()
        view.colorTint = .clear
        view.blurRadius = 35

        return view
    }()

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    let scrollView: UIScrollView = {
        let view = SmartScroll()
        view.contentLayoutGuide.widthAnchor.constraint(equalTo: view.frameLayoutGuide.widthAnchor).isActive = true
        view.scrollIndicatorInsets = .init(top: 16 / 2, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    let gradientView: GradientView2 = {
        let gradientView = GradientView2(colors: isDarkTheme() ? [UIColor.hex("#0D3BA9"), UIColor.hex("#982584"), UIColor.hex("#B52B23"), UIColor.hex("#B87C23")] : [UIColor.hex("#B7CCFF"), UIColor.hex("#FFAFF1"), UIColor.hex("#FFBDB9"), UIColor.hex("#FFE5BD"), UIColor.hex("#FFDEAC")], direction: .horizontal)
        
        return gradientView
    }()
    let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "premiumimage"))
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = false
        return view
    }()
    let premiumLabel: UILabel = {
        let view = UILabel()
        view.minimumScaleFactor = 0.8
        view.numberOfLines = 1
        view.font = Fonts.heading1
        view.text = "Premium Features".localizable()
        view.adjustsFontSizeToFitWidth = true
        view.textColor = UIColor(named: "TAHeading")
        return view
    }()
    let infoLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = "No additional purchases, just a".localizable().at.attributed { attr in
            attr.font(Fonts.heading5).foreground(color: UIColor(named: "TAHeading")!)
        } + " ".at.attributed { $0 } + "one-time purchase!".localizable().at.attributed { attr in
            attr.font(Fonts.heading5).foreground(color: UIColor(named: "TAHeading")!)
        }
        view.textAlignment = .center
        return view
    }()
    let plusesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0.008928571428571 * UIScreen.main.bounds.height
        return stack
    }()
    let save50Label: UIView = {
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
    let notaSubscriptionLabel: UIView = {
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
    let buyButton: NewCustomButton = {
        let button = NewCustomButton()
        button.addTarget(self, action: #selector(clickedOnBuy), for: .touchUpInside)
        button.stateBackgroundColor = .init(highlighted: .hex("#242424"), normal: .hex("#FF9900"))
        button.setTitle("\("Only".localizable(comment: "Only $2.99")) \(InAppManager.shared.productPrice)", for: .normal)
        button.setTitleColor(.hex("#242424"), for: .normal)
        button.setTitleColor(.hex("#FF9900"), for: .highlighted)
        button.titleLabel?.font = Fonts.heading2
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()
    let restoreButton: NewCustomButton = {
        let button = NewCustomButton()
        button.addTarget(self, action: #selector(clickedOnRestore), for: .touchUpInside)
        button.setTitle("Restore Purchase".localizable(), for: .normal)
        button.opacityState = .init(highlighted: 0.5, normal: 1)
        button.setTitleColor(.hex("#447bfe"), for: .normal)
        button.titleLabel?.font = Fonts.heading4
        button.titleLabel?.textAlignment = .center
        return button
    }()
    let bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "TAAltBackground")
        return view
    }()

    private let notification: LimitNotification?
    
    init(notification: LimitNotification? = nil) {
        self.notification = notification
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.flashScrollIndicators()
        gradientView.animateLocations(duration: Constants.animationDefaultDuration * 12)
        if let notification = notification {
            Drop.down(notification.text, state: .info, duration: 2, action: .none)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")!
        applySharedNavigationBarAppearance()
        view.layout(containerView).leading(13).trailing(13).topSafe()
        containerView.layout(scrollView).top().leading().trailing()
        containerView.layout(bottomView).bottom().leading().trailing().top(scrollView.anchor.bottom)
        scrollView.layout(imageView).top(0.0390625 * UIScreen.main.bounds.height).leading((Constants.displayVersion2 ? 0.23 : 0.108695652173913) * UIScreen.main.bounds.width) { _, _ in .greaterThanOrEqual }
            .trailing((Constants.displayVersion2 ? 0.23 : 0.108695652173913) * UIScreen.main.bounds.width) { _, _ in .lessThanOrEqual }.centerX().height(imageView.anchor.width).multiply(0.922558922558923)
        scrollView.layout(gradientView).center(imageView.anchor.center, offsetY: 20).width(0.45 * UIScreen.main.bounds.width).height(0.45 * UIScreen.main.bounds.width)
        scrollView.layout(visualEffectView).edges()
        scrollView.bringSubviewToFront(imageView)
        scrollView.layout(premiumLabel).top(imageView.anchor.bottom, 0.029017857142857 * UIScreen.main.bounds.height).leading(30).trailing(30)
        scrollView.layout(plusesStack).top(premiumLabel.anchor.bottom, 0.017857142857143 * UIScreen.main.bounds.height).leading(30).trailing(15).bottom(35)
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlimited Tags".localizable()))
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlimited Reminders".localizable()))
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlock Archive".localizable()))
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlimited Prioritization".localizable()))
        bottomView.layout(save50Label).top(5).leading(30)
        bottomView.layout(notaSubscriptionLabel).top(5).leading(save50Label.anchor.trailing, 8).trailing(30)
        
        bottomView.layout(buyButton).top(notaSubscriptionLabel.anchor.bottom, 6).leading(30).trailing(30).height(60)
        bottomView.layout(infoLabel).top(buyButton.anchor.bottom, 0.011160714285714 * UIScreen.main.bounds.height).centerX().width(250).priority(999).leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }.bottom(0.013392857142857 * UIScreen.main.bounds.height)
        view.layout(restoreButton).top(containerView.anchor.bottom, 17).width(250).centerX().bottom(Constants.vcMinBottomPadding) { _, _ in .greaterThanOrEqual }
    }
    
    @objc func clickedOnBuy() {
        Haptic.impact(.light).generate()
        InAppManager.shared.purchaseProduct { [weak self] error in
            if let error = error {
                self?.handle(error)
            } else {
                print("Success buy")
            }
        }
    }
    @objc func clickedOnRestore() {
        InAppManager.shared.restorePurchases { [weak self] error in
            if let error = error {
                self?.handle(error)
            } else {
                print("Success restore")
            }
        }
    }
    
    private func handle(_ error: InAppError) {
        let message: String
        switch error {
        case .unknown: message = "Unknown error. Please contact support".localizable()
        case .clientInvalid: message = "Not allowed to make the payment".localizable()
        case .paymentInvalid: message = "The purchase identifier was invalid".localizable()
        case .paymentNotAllowed: message = "The device is not allowed to make the payment".localizable()
        case .storeProductNotAvailable: message = "The product is not available in the current storefront".localizable()
        case .cloudServicePermissionDenied: message = "Access to cloud service information is not allowed".localizable()
        case .cloudServiceNetworkConnectionFailed: message = "Could not connect to the network".localizable()
        case .cloudServiceRevoked: message = "User has revoked permission to use this cloud service".localizable()
        case .other(let other): message = other
        case .restoreFailed: message = "Restore failed".localizable()
        case .nothingToRestore: message = "You have nothing to restore".localizable()
        }
        let alertVc = UIAlertController(title: "Error".localizable(), message: message, preferredStyle: .alert)
        alertVc.addAction(.init(title: "OK".localizable(), style: .cancel, handler: nil))
        present(alertVc, animated: true, completion: nil)
    }

}

extension PremiumFeaturesVc {
    class PremiumFeatureView: UIView {
        let check = CheckboxView()
        let textLabel = UILabel()

        init(_ text: String) {
            super.init(frame: .zero)
            check.tint = .hex("#447BFE")
            check.configure(isChecked: true)
            textLabel.font = Fonts.text
            textLabel.text = text
            textLabel.numberOfLines = 0
            layout(check).top().leading().width(22).height(22)
            layout(textLabel).top(1).leading(check.anchor.trailing, 9).trailing().bottom(1)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class SmartScroll: UIScrollView, UIScrollViewDelegate {
        override func layoutSubviews() {
            super.layoutSubviews()
            isScrollEnabled = contentSize.height - 10 > frame.height
            self.delegate = self
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.bounces = scrollView.contentOffset.y > 1
        }
    }
    
    enum LimitNotification {
        case archiveLimit
        case dateToTaskLimit
        case tagsLimit
        case prioritiesLimit
        
        var text: String {
            switch self {
            case .archiveLimit:
                return "You can't open archive in free version".localizable()
            case .dateToTaskLimit:
                return "You can't have more than".localizable(comment: "more than reminders/tags/priorities") + "\(Constants.maximumDatesToTask) " + "reminders".localizable()
            case .tagsLimit:
                return "You can't have more than".localizable() + "\(Constants.maximumTags) " + "tags".localizable()
            case .prioritiesLimit:
                return "You can't set more than".localizable() + "\(Constants.maximumPriorities) " + "priorities".localizable()
            }
        }
    }
}
