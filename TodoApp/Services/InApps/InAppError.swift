//
//  InAppError.swift
//  TodoApp
//
//  Created by sergey on 12.01.2021.
//

import Foundation

enum InAppError {
    case unknown
    case clientInvalid
    case paymentInvalid
    case paymentNotAllowed
    case storeProductNotAvailable
    case cloudServicePermissionDenied
    case cloudServiceNetworkConnectionFailed
    case cloudServiceRevoked
    case restoreFailed
    case nothingToRestore
    case other(String)
}
extension InAppError {
    var message: String {
        switch self {
        case .unknown: return "Unknown error. Please contact support".localizable()
        case .clientInvalid: return "Not allowed to make the payment".localizable()
        case .paymentInvalid: return "The purchase identifier was invalid".localizable()
        case .paymentNotAllowed: return "The device is not allowed to make the payment".localizable()
        case .storeProductNotAvailable: return "The product is not available in the current storefront".localizable()
        case .cloudServicePermissionDenied: return "Access to cloud service information is not allowed".localizable()
        case .cloudServiceNetworkConnectionFailed: return "Could not connect to the network".localizable()
        case .cloudServiceRevoked: return "User has revoked permission to use this cloud service".localizable()
        case .other(let other): return other
        case .restoreFailed: return "Restore failed".localizable()
        case .nothingToRestore: return "You have nothing to restore".localizable()
        }
    }
}
