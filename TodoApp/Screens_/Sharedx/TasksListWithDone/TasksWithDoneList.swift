//
//  TasksWithDoneList.swift
//  TodoApp
//
//  Created by sergey on 24.12.2020.
//

import Foundation
import UIKit
import Material
import RxDataSources
import RxSwift

class TasksWithDoneList: UIView {
    typealias DataSource = RxTableViewSectionedAnimatedDataSource<AnimSection<Model>>
    lazy var tableView = UITableView()
    private lazy var dataSource: DataSource = makeDataSource()
    private let bag = DisposeBag()
    private let onSelected: (RlmTask) -> Void
    private var currentItems: [AnimSection<Model>]?
    let itemsInput = PublishSubject<[RlmTask]>()
    
    init(onSelected: @escaping (RlmTask) -> Void) {
        self.onSelected = onSelected
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layout(tableView).edges()
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.register(TasksListTaskCell.self, forCellReuseIdentifier: TasksListTaskCell.reuseIdentifier)
        tableView.register(DoneTasksListTaskCell.self, forCellReuseIdentifier: DoneTasksListTaskCell.reuseIdentifier)
        tableView.delegate = self
        itemsInput.map { tasks -> [AnimSection<Model>] in
            let section1 = tasks.filter { !$0.isDone }.flatMap { [TasksWithDoneList.Model.task($0), TasksWithDoneList.Model.space(7)] }.dropLast()
            let section2 = tasks.filter { $0.isDone }.flatMap { [TasksWithDoneList.Model.doneTask($0), TasksWithDoneList.Model.space(7)] }.dropLast()
            let combinedItems = Array(section1.isEmpty ? section2 : section1 + [.space(45)] + section2)
            return [AnimSection(items: combinedItems)]
        }
        .do(onNext: { [weak self] in
            self?.currentItems = $0
        })
        .bind(to: tableView.rx.items(dataSource: dataSource))
        .disposed(by: bag)
    }

    func makeDataSource() -> DataSource {
        DataSource { (data, tableView, indexPath, model) -> UITableViewCell in
            switch model {
            case let .task(task):
                let taskCell = tableView.dequeueReusableCell(withIdentifier: TasksListTaskCell.reuseIdentifier, for: indexPath) as! TasksListTaskCell
                taskCell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasChecklist: !task.subtask.isEmpty) {
                    _ = try! RealmProvider.main.realm.write {
                        task.isDone.toggle()
                    }
                }
                taskCell.selectionStyle = .none

                return taskCell
            case let .doneTask(task):
                let doneCell = tableView.dequeueReusableCell(withIdentifier: DoneTasksListTaskCell.reuseIdentifier, for: indexPath) as! DoneTasksListTaskCell
                doneCell.configure(text: task.name) {
                    _ = try! RealmProvider.main.realm.write {
                        task.isDone.toggle()
                    }
                }
                doneCell.selectionStyle = .none

                return doneCell
            case .space:
                let cell = UITableViewCell()
                cell.backgroundColor = .clear
                cell.selectionStyle = .none
                return cell
            }
        }
    }
}

extension TasksWithDoneList: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let currentItems = currentItems else { return UITableView.automaticDimension }
        let item = currentItems[indexPath.section].items[indexPath.row]
        switch item {
        case .task:
            return 62
        case .doneTask:
            return 24
        case let .space(spacing):
            return spacing
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentItems = currentItems else { return }
        let item = currentItems[indexPath.section].items[indexPath.row] // TODO: Somewhy crashes
        switch item {
        case let .task(task):
            onSelected(task)
        case let .doneTask(task):
            onSelected(task)
        default: break
        }
    }
}

extension TasksWithDoneList {
    enum Model: IdentifiableType, Equatable {
        case task(RlmTask)
        case doneTask(RlmTask)
        case space(CGFloat)
        
        var identity: String {
            switch self {
            case .task(let task), .doneTask(let task):
                return task.isInvalidated ? "deleted-\(UUID().uuidString)" : task.id
            case .space:
                return UUID().uuidString
            }
        }
    }
}
