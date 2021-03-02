//
//  SmallCountWidget.swift
//  ControlWidgetExtension
//
//  Created by sergey on 28.02.2021.
//

import Foundation
import SwiftUI
import WidgetKit

struct SmallCountWidgetView: View {
    var entry: TasksCountEntry
    var mode: Mode
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .bottom, endPoint: .top)
            Image(imageName).bottomLeft()
            .padding(EdgeInsets(top: 0, leading: 12, bottom: 12, trailing: 0))
            VStack(spacing: 0) {
                HStack {
                    Text(title).font(Fonts.heading2.suiFont)
                        .foregroundColor(titleColor)
                    Spacer()
                }
                HStack {
                    Text("\(entry.tasksCount)").font(Fonts.heading1.suiFont)
                        .foregroundColor(Color(UIColor.hex("#242424")))
                    Spacer()
                }.offset(x: 0, y: -4)
            }
            .topLeft().padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 0))
        }
    }
    
    var gradientColors: [Color] {
        switch mode {
        case .today:
            return [Color(UIColor.hex("#F3EEDB")), Color(UIColor.hex("#FEF8EA"))]
        case .inbox:
            return [Color(UIColor.hex("#EED9FF")), Color(UIColor.hex("#F2EDFF"))]
        case .priority:
            return [Color(UIColor.hex("#FFD9E7")), Color(UIColor.hex("#FFF6ED"))]
        }
    }
    
    var imageName: String {
        switch mode {
        case .inbox: return "inbox"
        case .priority: return "flag"
        case .today: return "today"
        }
    }
    
    var title: String {
        switch mode {
        case .inbox: return "Inbox".localizable()
        case .priority: return "Priority".localizable()
        case .today: return "Today".localizable()
        }
    }
    var titleColor: Color {
        switch mode {
        case .inbox: return Color(UIColor.hex("#571CFF"))
        case .today: return Color(UIColor.hex("#FF9900"))
        case .priority: return Color(UIColor.hex("#EF4439"))
        }
    }
    
}

extension SmallCountWidgetView {
    enum Mode: String {
        case today
        case inbox
        case priority
        
        var tasksCountProviderMode: TasksCountProvider.Mode {
            switch self {
            case .inbox: return .inbox
            case .priority: return .priority
            case .today: return .today
            }
        }
    }
}

struct SmallCountWidget: Widget {
    var mode: SmallCountWidgetView.Mode = .inbox
    var kind: String { "SmallCount\(mode.rawValue)" }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasksCountProvider(mode: mode.tasksCountProviderMode)) { entry in
            SmallCountWidgetView(entry: entry, mode: mode)
        }
        .configurationDisplayName(displayName)
        .description(description)
        .supportedFamilies([.systemSmall])
    }
    
    var displayName: String {
        switch self.mode {
        case .inbox: return "Inbox".localizable()
        case .priority: return "Priority".localizable()
        case .today: return "Today".localizable()
        }
    }
    var description: String {
        return "Get short summary of your current tasks".localizable()
    }
}


struct SmallCountWidgetView_Previews: PreviewProvider {
    static func group() -> some View {
        Group {
            SmallCountWidgetView(entry: .init(date: .init(), tasksCount: 7), mode: .priority)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            SmallCountWidgetView(entry: .init(date: .init(), tasksCount: 7), mode: .today)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            SmallCountWidgetView(entry: .init(date: .init(), tasksCount: 7), mode: .inbox)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }

    static var previews: some View {
        Group {
            group()
            group().preferredColorScheme(.dark)
        }
    }
}
