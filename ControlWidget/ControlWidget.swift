//
//  ControlWidget.swift
//  ControlWidget
//
//  Created by sergey on 26.02.2021.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let tasks = Array(RealmProvider.main.realm.objects(RlmTask.self)).map { ($0.isDone ? "V " : "X ") + $0.name + "\(Int.random(in: 1...9))" }

        let entry = SimpleEntry(date: .init(), taskNames: tasks)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let tasks = Array(RealmProvider.main.realm.objects(RlmTask.self)).map { ($0.isDone ? "V " : "X ") + $0.name + "\(Int.random(in: 1...9))" }
        let timeline = Timeline(entries: [SimpleEntry(date: .init(), taskNames: tasks)], policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), taskNames: ["fww"])
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let taskNames: [String]
}

struct ControlWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color.white
        VStack(content: {
            ForEach(0..<entry.taskNames.count) { int in
                Text(entry.taskNames[int]).foregroundColor(Color.black)
            }
        })
        }
    }
}

struct ControlWidget: Widget {
    let kind: String = "hey you"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ControlWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hey youuuu")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}
struct ControlWidget2: Widget {
    let kind: String = "Hww"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ControlWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Hww")
        .description("I set it up")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

@main
struct ControlBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        ControlWidget()
        ControlWidget2()
    }
}

struct ControlWidget_Previews: PreviewProvider {
    static var previews: some View {
        ControlWidgetEntryView(entry: SimpleEntry(date: Date(), taskNames: ["wefwqf"]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
