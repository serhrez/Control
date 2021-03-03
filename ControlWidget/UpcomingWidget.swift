//
//  UpcomingWidget.swift
//  TodoApp
//
//  Created by sergey on 28.02.2021.
//

import WidgetKit
import SwiftUI

struct UpcomingWidgetView: View {
    var entry: TasksCountEntry

    var body: some View {
        ZStack {
            Color(UIColor(named: "TAAltBackground")!)
            VStack(spacing: 0) {
                HStack {
                    Text("Upcoming")
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(Color(UIColor.hex("#447bfe")))
                        .font(Fonts.heading3.suiFont)
                    Spacer()
                }
                HStack {
                    Text("\(entry.tasksCount)")
                        .foregroundColor(Color(UIColor(named: "TAHeading")!))
                        .font(Fonts.heading1.suiFont)
                    Spacer()
                }
                HStack {
                    Text("next 7 days".localizable())
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .foregroundColor(Color(UIColor(named: "TAHeading")!))
                        .font(Fonts.heading6.suiFont)
                    Spacer()
                }.offset(x: 0, y: -5)
                Spacer()
            }.padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 8))
            VStack {
                Spacer()
                HStack {
                    Image("calendar")
                    Spacer()
                }
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 11, trailing: 0))
        }
    }
}

struct UpcomingWidget: Widget {
    let kind: String = "UpcomingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasksCountProvider(mode: .upcoming)) { entry in
            UpcomingWidgetView(entry: entry)
        }
        .configurationDisplayName("Upcoming".localizable())
        .description("Be notified about all the events in the next 7 days".localizable())
        .supportedFamilies([.systemSmall])
    }
}


struct UpcomingWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingWidgetView(entry: .init(date: .init(), tasksCount: 7))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
