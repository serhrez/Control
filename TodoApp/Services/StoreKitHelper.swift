//
//  StoreKitHelper.swift
//  TodoApp
//
//  Created by sergey on 21.02.2021.
//

import Foundation
import StoreKit

enum StoreKitHelper {
    static func maybeDisplayStoreKit(windowScene: UIWindowScene) {
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
            return
        }
        
        let lastVersionPromptedForReview = UserDefaultsWrapper.shared.lastVersionPromptedForReview
        let numberOfTimesLaunched = UserDefaultsWrapper.shared.numberOfTimesLaunched
        
        if numberOfTimesLaunched >= 5 && currentVersion != lastVersionPromptedForReview && (numberOfTimesLaunched % 3 == 0 || numberOfTimesLaunched == 5) {
            SKStoreReviewController.requestReview(in: windowScene)
            UserDefaultsWrapper.shared.lastVersionPromptedForReview = currentVersion
        }
    }
    
    static func incrementNumberOfTimesLaunched() {
        UserDefaultsWrapper.shared.numberOfTimesLaunched += 1
    }
}
