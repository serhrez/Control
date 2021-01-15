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

    let containerView: UIScrollView = {
        let view = SmartScroll()
        view.contentLayoutGuide.widthAnchor.constraint(equalTo: view.frameLayoutGuide.widthAnchor).isActive = true
        view.backgroundColor = UIColor(named: "TAAltBackground")
        view.layer.cornerRadius = 16
        view.scrollIndicatorInsets = .init(top: 16 / 2, left: 0, bottom: 16 / 2, right: 0)
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
        button.stateBackgroundColor = .init(highlighted: .red, normal: .hex("#FFE600"))
        button.setTitle("Only $4,99", for: .normal)
        button.setTitleColor(UIColor(named: "TAHeading")!, for: .normal)
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
        containerView.flashScrollIndicators()
        if let notification = notification {
            Drop.down(notification.text, state: .info, duration: 2, action: .none)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")!
        applySharedNavigationBarAppearance()
        view.layout(containerView).leading(13).trailing(13).topSafe()
        containerView.layout(imageView).top(22).leading(21) { _, _ in .greaterThanOrEqual }
            .trailing(21) { _, _ in .lessThanOrEqual }.centerX().height(imageView.anchor.width).multiply(0.8216)
        containerView.layout(premiumLabel).top(imageView.anchor.bottom, 33.2).leading(30).trailing(30)
        containerView.layout(plusesStack).top(premiumLabel.anchor.bottom, 30).leading(30).trailing(30)
        plusesStack.addArrangedSubview(getHorizontalStack("Unlimited Tasks"))
        plusesStack.addArrangedSubview(getHorizontalStack("Unlimited reminders"))
        plusesStack.addArrangedSubview(getHorizontalStack("Unlock Archive"))
        plusesStack.addArrangedSubview(getHorizontalStack("Constant improvements and new features"))
        containerView.layout(buyButton).top(plusesStack.anchor.bottom, 35).leading(30).trailing(30).height(60)
        containerView.layout(infoLabel).top(buyButton.anchor.bottom, 25).centerX().width(250).priority(999).leading() { _, _ in .greaterThanOrEqual }.trailing() { _, _ in .lessThanOrEqual }.bottom(25)
        view.layout(restoreButton).top(containerView.anchor.bottom, 17).width(250).centerX().bottom(Constants.vcMinBottomPadding) { _, _ in .greaterThanOrEqual }
    }
    
    func getHorizontalStack(_ text: String) -> UIStackView {
        let check = CheckboxView()
        check.tint = .hex("#447BFE")
        check.configure(isChecked: true)
        let textLabel = UILabel()
        textLabel.font = .systemFont(ofSize: 16, weight: .regular)
        textLabel.text = text
        let horizontalStack = UIStackView(arrangedSubviews: [check, textLabel, UIView()])
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 9
        return horizontalStack
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
