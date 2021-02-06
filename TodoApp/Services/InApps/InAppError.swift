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
        case .unknown: return "Unknown error. Please contact support"
        case .clientInvalid: return "Not allowed to make the payment"
        case .paymentInvalid: return "The purchase identifier was invalid"
        case .paymentNotAllowed: return "The device is not allowed to make the payment"
        case .storeProductNotAvailable: return "The product is not available in the current storefront"
        case .cloudServicePermissionDenied: return "Access to cloud service information is not allowed"
        case .cloudServiceNetworkConnectionFailed: return "Could not connect to the network"
        case .cloudServiceRevoked: return "User has revoked permission to use this cloud service"
        case .other(let other): return other
        case .restoreFailed: return "Restore failed"
        case .nothingToRestore: return "You have nothing to restore"
        }
    }
}
