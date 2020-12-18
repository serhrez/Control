//
//  PlannedVcVm.swift
//  TodoApp
//
//  Created by sergey on 15.12.2020.
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxCocoa
import SwiftDate

class PlannedVcVm {
    private let tasks: Results<RlmTask>
    private let bag = DisposeBag()
    private var tokens: [NotificationToken] = []
    private let datePrioritiesHolder = DatePrioritiesHolder()

    private let noCalendarModelsUpdateSubject = PublishSubject<Void>()
    let noCalendarModelsUpdate = BehaviorRelay<[AnimDateSection<Model>]>(value: [])
    
    private let calendarModelsUpdateSubject = PublishSubject<Date>()
    let calendarModelsUpdate = BehaviorRelay<[AnimSection<Model>]>(value: [])
    init() {
        tasks = RealmProvider.main.realm.objects(RlmTask.self)
        noCalendarModelsUpdateSubject.subscribe(onNext: updateModels).disposed(by: bag)
        let tasksToken = tasks.observe { [unowned self] _ in
            noCalendarModelsUpdateSubject.onNext(())
            // setupDatesSet()
        }
        calendarModelsUpdateSubject
            .compactMap { [weak self] date -> [RlmTask]? in
                guard let self = self else { return nil }
                let filtered = self.tasks.filter { (task: RlmTask) -> Bool in
                    task.date?.date?.dateAt(.startOfDay) == date//.dateAt(.startOfDay)
                }
                return Array(filtered)
            }
            .compactMap { [weak self] in
                return self?.reordered($0.map { Model.task($0) })
            }
            .map { [AnimSection(items: $0)] }
            .subscribe(onNext: calendarModelsUpdate.accept)
            .disposed(by: bag)
        updateModels()
        tokens.append(tasksToken)
        datePrioritiesHolder.updateDatesSet()
    }
        
    func updateModels() {
        var taskDates: [Date: [RlmTask]] = [:]
        for task in tasks.filter({ $0.date?.date != nil }) {
            let startDate = task.date!.date!.dateAtStartOf(.day)
            if taskDates[startDate] != nil {
                taskDates[startDate]!.append(task)
            } else {
                taskDates[startDate] = [task]
            }
        }
        let sections = taskDates.map { AnimDateSection(date: $0.key, items: reordered($0.value.map { Model.task($0) })) }
            .sorted(by: { $0.date < $1.date })
        noCalendarModelsUpdate.accept(sections)
    }
    
    func reordered(_ models: [Model]) -> [Model] {
        return models.filter { $0.task.date?.date != nil }.sorted(by: { model1, model2 in
            return model1.task.date!.date! <= model2.task.date!.date!
        })
    }
    
    func setIsDone(_ isDone: Bool, to task: RlmTask) {
        _ = try! RealmProvider.main.realm.write {
            task.isDone = isDone
        }
    }
    
    func selectDayFromJct(_ date: Date) {
        calendarModelsUpdateSubject.onNext(date.dateAt(.startOfDay))
    }
    
    func datePriorities(_ date: Date) -> (blue: Bool, orange: Bool, red: Bool, gray: Bool) {
        return datePrioritiesHolder.datePriorities(date)
    }
}

extension PlannedVcVm {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask)
        var task: RlmTask {
            switch self {
            case let .task(task):
                return task
            }
        }
        var identity: String {
            return task.isInvalidated ? "\(UUID().uuidString)" : task.id
        }
    }
}

extension PlannedVcVm {
    struct AnimDateSection<Item: IdentifiableType & Equatable>: AnimatableSectionModelType, IdentifiableType {
        var items: [Item]
        var date: Date
        var identity: String { date.toFormat("yyyy mm dd") }
        
        init(original: AnimDateSection<Item>, items: [Item]) {
            self = original
            self.items = items
        }
        
        init(date: Date, items: [Item]) {
            self.date = date
            self.items = items
        }
    }
}
