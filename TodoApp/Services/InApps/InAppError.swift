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
