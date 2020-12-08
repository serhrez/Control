//
//  AlignmentRectViews.swift
//  TodoApp
//
//  Created by sergey on 08.12.2020.
//

import Foundation
import UIKit

class ALUILabel: UILabel {
    var alignmentRectInsetsValues: UIEdgeInsets = .zero
    override var alignmentRectInsets: UIEdgeInsets { alignmentRectInsetsValues }
}
