//
//  PremiumFeaturesVc.swift
//  TodoApp
//
//  Created by sergey on 11.01.2021.
//

import Foundation
import UIKit
import Material

class PremiumFeaturesVc: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let button = UIButton(type: .system)
        button.setTitle("Only $4,99", for: .normal)
        button.addTarget(self, action: #selector(clickedOnBuy), for: .touchUpInside)
        button.backgroundColor = .yellow
        view.layout(button).center().width(200).height(50)
        let button2 = UIButton(type: .system)
        button2.setTitle("Restore", for: .normal)
        button2.addTarget(self, action: #selector(clickedOnRestore), for: .touchUpInside)
        button2.backgroundColor = .green
        view.layout(button2).centerX().centerY(100).width(200).height(50)
        print("premium enabled: \(UserDefaultsWrapper.shared.isPremium)")
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
        switch error {
        case .unknown: print("Unknown error. Please contact support")
        case .clientInvalid: print("Not allowed to make the payment")
        case .paymentInvalid: print("The purchase identifier was invalid")
        case .paymentNotAllowed: print("The device is not allowed to make the payment")
        case .storeProductNotAvailable: print("The product is not available in the current storefront")
        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
        case .other(let other): print(other)
        case .restoreFailed: print("Restore failed")
        case .nothingToRestore: print("You have nothing to restore")
        }
    }

}
