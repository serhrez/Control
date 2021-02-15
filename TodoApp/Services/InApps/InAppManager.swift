//
//  InAppManager.swift
//  TodoApp
//
//  Created by sergey on 11.01.2021.
//

import Foundation
import SwiftyStoreKit

class InAppManager {
    var product: InAppProduct?
    var productPrice: String {
        product?.localizedString ?? "$2,99"
    }
    let productId = "com.sergeyreznichenko.control.premiumver"
    
    static let shared = InAppManager()
    
    init() {
        completeTransactions()
        fetchProduct()
    }
    
    func restorePurchases(completion: @escaping (InAppError?) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if let restoredProduct = results.restoredPurchases.filter { $0.productId == self.productId }.first {
                UserDefaultsWrapper.shared.isPremium = true
                completion(nil)
            } else if results.restoreFailedPurchases.count > 0 {
                completion(.restoreFailed)
                print("Restore failed: \(results.restoreFailedPurchases)")
            } else {
                completion(.nothingToRestore)
                print("Nothing to restore")
            }
        }
    }
    
    func purchaseProduct(completion: @escaping (InAppError?) -> Void) {
        SwiftyStoreKit.purchaseProduct(productId, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                UserDefaultsWrapper.shared.isPremium = true
                completion(nil)
            case .error(let error):
                switch error.code {
                case .unknown: completion(.unknown)
                case .clientInvalid: completion(.clientInvalid)
                case .paymentCancelled: break
                case .paymentInvalid: completion(.paymentInvalid)
                case .paymentNotAllowed: completion(.paymentNotAllowed)
                case .storeProductNotAvailable: completion(.storeProductNotAvailable)
                case .cloudServicePermissionDenied: completion(.cloudServicePermissionDenied)
                case .cloudServiceNetworkConnectionFailed: completion(.cloudServiceNetworkConnectionFailed)
                case .cloudServiceRevoked: completion(.cloudServiceRevoked)
                default: completion(.other((error as NSError).localizedDescription))
                }
            }
        }
    }
    
    private func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("compleTransaction .purchased, .restored")
                case .failed, .purchasing, .deferred:
                    break
                @unknown default: break
                }
            }
        }
    }
    
    private func fetchProduct() {
        SwiftyStoreKit.retrieveProductsInfo([productId]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.product = InAppProduct(localizedString: priceString)
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }

    }
}

