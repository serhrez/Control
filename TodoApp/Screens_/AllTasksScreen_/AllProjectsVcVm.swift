//
//  AllProjectsVcVM.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import RealmSwift

class AllProjectsVcVM {
    typealias TableUpdatesFunc = (_ deletions: [Int], _ insertions: [Int], _ modifications: [Int]) -> Void
    private var projects: [RlmProject] = []
    var models: [Model] {
        var models = [getTodayModel(), getPriorityModel(), getPlannedModel()]
            + projects.sorted(by: { $0.createdAt < $1.createdAt }).map { Model.project($0) }
        
        if let inbox = getInboxModel() {
            models.insert(inbox, at: 0)
        }
        return models + [.addProject]
    }
    private var tokens: [NotificationToken] = []
    var tableUpdates: TableUpdatesFunc?
    var initialValues: (() -> Void)?
    
    init() {
        let token = RealmProvider.main.realm.objects(RlmProject.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .update(projects, deletions: deletions, insertions: insertions, modifications: modifications):
                self.projects = Array(projects
                                        .filter { $0.id != Constants.inboxId }
                                        .sorted(by: { prj1, prj2 in prj1.createdAt > prj2.createdAt }))
                self.tableUpdates?(deletions, insertions, modifications)
            case let .initial(projects):
                self.projects = Array(projects
                                        .filter { $0.id != Constants.inboxId }
                                        .sorted(by: { prj1, prj2 in prj1.createdAt > prj2.createdAt }))
                self.initialValues?()
            case let .error(error):
                print(error)
            }
        }
        tokens.append(token)
    }
    
    func getInboxModel() -> Model? {
        let project = RealmProvider.main.realm.objects(RlmProject.self).filter { $0.id == Constants.inboxId }.first
        return project.flatMap { .inboxProject($0) }
    }
    
    func getPriorityModel() -> Model {
        let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.priority != .none }
        let count = tasks.count
        let progress: Double
        if count == 0 {
            progress = 0
        } else {
            progress = Double(tasks.filter { $0.isDone }.count) / Double(count)
        }
        return .priority(.init(icon: .assetImage(name: "flag", tintHex: "#EF4439"), iconFontSize: 18, name: "Priority".localizable(), progress: progress, tasksCount: count, color: .hex("#EF4439")))
    }
    
    func getTodayModel() -> Model {
        let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.date?.date?.isToday ?? false }
        let count = tasks.count
        let progress: Double
        if count == 0 {
            progress = 0
        } else {
            progress = Double(tasks.filter { $0.isDone }.count) / Double(count)
        }
        return .today(.init(icon: .assetImage(name: "today", tintHex: nil), iconFontSize: 25, name: "Today".localizable(), progress: progress, tasksCount: count, color: .hex("#FF9900")))
    }
    
    func getPlannedModel() -> Model {
        let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.date?.date != nil }
        let count = tasks.count
        let progress: Double
        if count == 0 {
            progress = 0
        } else {
            progress = Double(tasks.filter { $0.isDone }.count) / Double(count)
        }
        return .planned(.init(icon: .assetImage(name: "calendar", tintHex: "#447bfe"), iconFontSize: 21, name: "Planned".localizable(), progress: progress, tasksCount: count, color: .hex("#447bfe")))
    }
    
    func progressForPlannedWithCount() -> (Double, Int) {
        let tasks = RealmProvider.main.realm.objects(RlmTask.self).filter { $0.date?.date != nil }
        let count = tasks.count
        if count == 0 {
            return (0, 0)
        } else {
            return (Double(tasks.filter { $0.isDone }.count) / Double(count), count)
        }
    }
    
    func getProgress(for project: RlmProject) -> Double {
        let count = project.tasks.count
        if count == 0 {
            return 0
        } else {
            return Double(project.tasks.filter { $0.isDone }.count) / Double(count)
        }
    }
    
    enum Model {
        case inboxProject(RlmProject)
        case today(PredefinedProjectModel)
        case priority(PredefinedProjectModel)
        case planned(PredefinedProjectModel)
        case project(RlmProject)
        case addProject
    }
    
    struct PredefinedProjectModel {
        var icon: Icon
        var iconFontSize: CGFloat? = nil
        var name: String
        var progress: Double
        var tasksCount: Int
        var color: UIColor
    }
}
