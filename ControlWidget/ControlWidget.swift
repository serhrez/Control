//
//  ControlWidget.swift
//  ControlWidget
//
//  Created by sergey on 26.02.2021.
//

import WidgetKit
import SwiftUI
@main
struct BundleWidget: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        UpcomingWidget()
//        SmallCountWidget(mode: .inbox)
        SmallCountWidget(mode: .priority)
        SmallCountWidget(mode: .today)
        CheckmarksWidget(isOrangeMode: false)
        CheckmarksWidget(isOrangeMode: true)
    }
}
