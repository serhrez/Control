//
//  DebugView.swift
//  TodoApp
//
//  Created by sergey on 10.01.2021.
//

import Foundation
import UIKit

enum DebugView {
    static func addViewPoint(to view: UIView, origin: CGPoint, color: UIColor = .red, after delay: TimeInterval = 0.5) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let redView = UIView()
            redView.backgroundColor = color
            let c = CGRect(x: origin.x, y: origin.y, width: 10, height: 10)
            redView.frame = c
            view.addSubview(redView)
        }
    }
}
