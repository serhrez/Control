//
//  CheckmarksWidget.swift
//  TodoApp
//
//  Created by sergey on 28.02.2021.
//

import SwiftUI
import WidgetKit

struct CheckboxView: View {
    var priority: Priority
    var isDone = false
    private var color: Color {
        isDone ? Color(UIColor.hex("#447bfe")) : Color(priority.color)
    }
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(color)
                .frame(width: 18, height: 18)
                .cornerRadius(6)
                .opacity(isDone ? 1 : 0.3)
            RoundedRectangle(cornerRadius: 6)
                .stroke(color, lineWidth: 2)
                .frame(width: 18, height: 18)
                .frame(width: 20, height: 20)
            if isDone {
                Image("check").resizable().frame(width: 10, height: 7.27)
            }
        }
    }
}

struct SimpleCell: View {
    var task: TasksEntry.Task
    var body: some View {
        HStack(spacing: 0) {
            if task.isAllDone {
                Text("All Done!".localizable())
                    .font(Fonts.heading4.suiFont)
                    .foregroundColor(color)
                Spacer()
            } else {
                CheckboxView(priority: task.priority, isDone: task.isDone)
                    .opacity(task.isPlaceholder ? 0 : 1)
                Spacer().frame(width: 10, height: 0, alignment: .center)
                Text(task.name)
                    .font(Fonts.heading4.suiFont)
                    .foregroundColor(color)
                    .strikethrough(task.isDone, color: color)
                Spacer(minLength: 10)
                Text(task.time)
                    .font(Fonts.heading4.suiFont)
                    .foregroundColor(Color(UIColor(named: "TASubElement")!))
            }
        }
    }
    var color: Color {
        Color(task.isDone ? UIColor(named: "TASubElement")! : UIColor(named: "TAHeading")!)
    }
}

struct SimpleCell2: View {
    var task: TasksEntry.Task
    var nameColor: Color
    var taskName: String {
        var taskName = task.name
        if task.isAllDone {
            taskName = "All Done!".localizable()
        }
        return taskName
    }
    var body: some View {
        Text(taskName)
            .font(Fonts.heading5.suiFont)
            .foregroundColor(nameColor)
            .left()
    }
}

struct CheckmarksWidgetView: View {
    var entry: TasksEntry
    @Environment(\.widgetFamily) var family: WidgetFamily
    var isOrangeMode = false
    
    var body: some View {
        ZStack {
            backgroundColor
            VStack(spacing: 0) {
                Spacer().frame(width: 1, height: 13, alignment: .center)
                if family == .systemLarge && !isOrangeMode {
                    HStack {
                        Text("Today".localizable())
                            .font(Fonts.heading2.suiFont)
                            .foregroundColor(nameColor)
                        Spacer()
                        Text(Date().toFormat("dd MMMM"))
                            .font(Fonts.heading6.suiFont)
                            .foregroundColor(subColor)
                    }
                } else {
                    Text("Today".localizable())
                        .font(Fonts.heading2.suiFont)
                        .foregroundColor(nameColor)
                        .left()
                    Text(Date().toFormat("dd MMMM"))
                        .font(Fonts.heading6.suiFont)
                        .foregroundColor(subColor)
                        .padding(EdgeInsets(top: -1, leading: 0, bottom: 0, trailing: 0))
                        .left()
                }
                VStack(spacing: tasksSpacing) {
                    ForEach(0..<maxTasks) { index in
                        if index < shownTasks {
                            getTextCell(task: tasks[index])
                        } else {
                            getTextCell(task: TasksEntry.Task.placeholder())
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                Text(tasksMore == 0 ? "" : "TasksMoreWidgetOneArgument".localizable(argument: "\(tasksMore)"))
                    .font(Fonts.heading6.suiFont)
                    .foregroundColor(subColor)
                    .left()
                Spacer().frame(width: 1, height: bottomMoreLabelSpacing, alignment: .center)
            }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 16))
        }
    }
    
    var tasks: [TasksEntry.Task] {
        if isOrangeMode || family != .systemLarge {
            let tasks = entry.tasks.filter { !$0.isDone }
            return tasks.isEmpty ? [TasksEntry.Task.allDoneTask()] : tasks
        } else {
            let tasks = entry.tasks
            return tasks.isEmpty ? [TasksEntry.Task.allDoneTask()] : tasks
        }
    }
    
    func getTextCell(task: TasksEntry.Task) -> AnyView {
        if family == .systemLarge && !isOrangeMode {
            return AnyView(SimpleCell(task: task))
        }
        return AnyView(SimpleCell2(task: task, nameColor: nameColor))
    }
    
    var tasksSpacing: CGFloat {
        if family == .systemLarge {
            return isOrangeMode ? 7 : 12
        }
        return 5
    }
    
    var maxTasks: Int {
        if family == .systemLarge {
            return isOrangeMode ? (Constants.displayVersion2 ? 9 : 11) : (Constants.displayVersion2 ? 7 : 8)
        }
        return 3
    }
    var bottomMoreLabelSpacing: CGFloat {
        Constants.displayVersion2 ? 12 : 17
    }
    var shownTasks: Int {
        min(tasks.count, maxTasks)
    }
    var tasksMore: Int {
        max(tasks.count - maxTasks, 0)
    }
    var backgroundColor: Color {
        if isOrangeMode {
            return Color(UIColor(hex: "#FF9900")!)
        } else {
            return Color(UIColor(named: "TAAltBackground")!)
        }
    }
    var nameColor: Color {
        if isOrangeMode {
            return Color(UIColor(hex: "#FFFFFF")!)
        } else {
            return Color(UIColor(named: "TAHeading")!)
        }
    }
    var subColor: Color {
        if isOrangeMode {
            return Color(UIColor(hex: "#FFDFAC")!)
        } else {
            return Color(UIColor(named: "TASubElement")!)
        }
    }
}

struct CheckmarksWidget: Widget {
    var isOrangeMode: Bool = false
    var kind: String { "CheckmarksWidget\(isOrangeMode ? "Orange" : "Normal")" }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TasksProvider()) { entry in
            CheckmarksWidgetView(entry: entry, isOrangeMode: isOrangeMode)
        }
        .configurationDisplayName(displayName)
        .description(description)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
    
    var displayName: String {
        isOrangeMode ? "Today Simplified".localizable() : "Today".localizable()
    }
    var description: String {
        return "Get quick access to your tasks for today".localizable()
    }
}


struct CheckmarksWidgetView_Previews: PreviewProvider {
    
    static func allTasks() -> [TasksEntry.Task] {
        [
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),
            TasksEntry.Task(priority: .high, name: "wefw", time: "32:30", isDone: false),

        ]
    }
    
    static func getWidgetView(isOrange: Bool = false) -> CheckmarksWidgetView {
        CheckmarksWidgetView(entry: TasksEntry(date: Date(), tasks: allTasks()), isOrangeMode: isOrange)
    }
    static func getAllPreviews() -> some View {
        Group {
        getWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        getWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        getWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        getWidgetView(isOrange: true)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        getWidgetView(isOrange: true)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        getWidgetView(isOrange: true)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
    static var previews: some View {
        Group {
            getAllPreviews()
            getAllPreviews().preferredColorScheme(.dark)
        }
    }
}
