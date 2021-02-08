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

class PremiumFeaturesVc: UIViewController {

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
    
    let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "premiumimage"))
        view.contentMode = .scaleAspectFit
        return view
    }()
    let premiumLabel: UILabel = {
        let view = UILabel()
        view.minimumScaleFactor = 0.8
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 36, weight: .bold)
        view.text = "Premium Features"
        view.adjustsFontSizeToFitWidth = true
        view.textColor = UIColor(named: "TAHeading")
        return view
    }()
    let infoLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.attributedText = "No additional purchases, just a ".at.attributed { attr in
            attr.font(.systemFont(ofSize: 16, weight: .regular)).foreground(color: UIColor(named: "TAHeading")!)
        } + "one-time purchase!".at.attributed { attr in
            attr.font(.systemFont(ofSize: 16, weight: .bold)).foreground(color: UIColor(named: "TAHeading")!)
        }
        view.textAlignment = .center
        return view
    }()
    let plusesStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        return stack
    }()
    let buyButton: NewCustomButton = {
        let button = NewCustomButton()
        button.addTarget(self, action: #selector(clickedOnBuy), for: .touchUpInside)
        button.stateBackgroundColor = .init(highlighted: .hex("#242424"), normal: .hex("#FFE600"))
        button.setTitle("Only \(InAppManager.shared.productPrice)", for: .normal)
        button.setTitleColor(.hex("#242424"), for: .normal)
        button.setTitleColor(.hex("#FFE600"), for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .heavy)
        button.layer.cornerRadius = 16
        button.layer.cornerCurve = .continuous
        return button
    }()
    let restoreButton: NewCustomButton = {
        let button = NewCustomButton()
        button.addTarget(self, action: #selector(clickedOnRestore), for: .touchUpInside)
        button.setTitle("Restore Purchase", for: .normal)
        button.opacityState = .init(highlighted: 0.5, normal: 1)
        button.setTitleColor(.hex("#447bfe"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
        scrollView.layout(imageView).top(22).leading(21) { _, _ in .greaterThanOrEqual }
            .trailing(21) { _, _ in .lessThanOrEqual }.centerX().height(imageView.anchor.width).multiply(0.8216)
        scrollView.layout(premiumLabel).top(imageView.anchor.bottom, 33.2).leading(30).trailing(30)
        scrollView.layout(plusesStack).top(premiumLabel.anchor.bottom, 30).leading(30).trailing(15).bottom(35)
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlimited Tags"))
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlimited Reminders"))
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlock Archive"))
        plusesStack.addArrangedSubview(PremiumFeatureView("Unlimited Prioritization"))
        bottomView.layout(buyButton).top(5).leading(30).trailing(30).height(60)
        bottomView.layout(infoLabel).top(buyButton.anchor.bottom, 0.0279 * UIScreen.main.bounds.height).centerX().width(250).priority(999).leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }.bottom(0.0279 * UIScreen.main.bounds.height)
        view.layout(restoreButton).top(containerView.anchor.bottom, 17).width(250).centerX().bottom(Constants.vcMinBottomPadding) { _, _ in .greaterThanOrEqual }
    }
    
    @objc func clickedOnBuy() {
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
        case .unknown: message = "Unknown error. Please contact support"
        case .clientInvalid: message = "Not allowed to make the payment"
        case .paymentInvalid: message = "The purchase identifier was invalid"
        case .paymentNotAllowed: message = "The device is not allowed to make the payment"
        case .storeProductNotAvailable: message = "The product is not available in the current storefront"
        case .cloudServicePermissionDenied: message = "Access to cloud service information is not allowed"
        case .cloudServiceNetworkConnectionFailed: message = "Could not connect to the network"
        case .cloudServiceRevoked: message = "User has revoked permission to use this cloud service"
        case .other(let other): message = other
        case .restoreFailed: message = "Restore failed"
        case .nothingToRestore: message = "You have nothing to restore"
        }
        let alertVc = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVc.addAction(.init(title: "OK", style: .cancel, handler: nil))
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
            textLabel.font = .systemFont(ofSize: 16, weight: .regular)
            textLabel.text = text
            textLabel.numberOfLines = 0
            layout(check).top().leading().width(22).height(22)
            layout(textLabel).top(1).leading(check.anchor.trailing, 9).trailing().bottom(1)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class SmartScroll: UIScrollView {
        override func layoutSubviews() {
            super.layoutSubviews()
            isScrollEnabled = contentSize.height - 10 > frame.height
        }
    }
    
    enum LimitNotification {
        case tasksLimit
        case archiveLimit
        case dateToTaskLimit
        
        var text: String {
            switch self {
            case .tasksLimit:
                return "You can have up to \(Constants.maximumTasksCount) tasks"
            case .archiveLimit:
                return "You can't open archive in free version"
            case .dateToTaskLimit:
                return "You can't have more than \(Constants.maximumDatesToTask) reminders"
            }
        }
    }
}
