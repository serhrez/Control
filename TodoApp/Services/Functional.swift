//
//  Functional.swift
//  TodoApp
//
//  Created by sergey on 19.05.2021.
//

import Foundation

precedencegroup ForwardApplication {
    associativity: left
}

infix operator <>

func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
    return { a in
        f(a)
        g(a)
    }
}
