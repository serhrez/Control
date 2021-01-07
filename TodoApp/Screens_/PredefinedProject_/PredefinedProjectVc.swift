//
//  PredefinedProjectVc.swift
//  TodoApp
//
//  Created by sergey on 07.01.2021.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift

class PredefinedProjectVc: UIViewController {
    private let mode: Mode
    private let bag = DisposeBag()
    private var tokens = [NotificationToken]()
    private let tasksSubject = PublishSubject<[RlmTask]>()
    lazy var tasksWithDoneList = TasksWithDoneList(onSelected: { [weak self] task in
        guard let self = self else { return }
        self.router.openTaskDetails(task)
    }, onChangeIsDone: { task in
        RealmProvider.main.safeWrite {
            task.isDone.toggle()
        }
    }, shouldDelete: { [weak self] task in
        guard let self = self,
              let project = task.project.first else { return }
        DBHelper.safeArchive(taskId: task.id, projectId: project.id)
        self.showBottomMessage(type: .taskDeleted) {
            DBHelper.safeUnarchive(taskId: task.id)
        }
    }, isGradientHidden: false)
    
    init(_ mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "TABackground")
        switch mode {
        case .priority:
            title = "Priority"
        case .today:
            title = "Today"
        }
        applySharedNavigationBarAppearance()
        view.layout(tasksWithDoneList).topSafe(20).leading(13).trailing(13).bottom()
        setupTasksWithDoneListBinding()
    }
    
    func setupTasksWithDoneListBinding() {
        tasksSubject
            .bind(to: tasksWithDoneList.itemsInput)
            .disposed(by: bag)
        let token = RealmProvider.main.realm.objects(RlmTask.self).observe(on: .main) { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case let .error(error):
                print(error)
            case let .initial(results), let .update(results, deletions: _, insertions: _, modifications: _):
                switch self.mode {
                case .priority:
                    self.tasksSubject.onNext(results.filter { $0.priority == .high })
                case .today:
                    self.tasksSubject.onNext(results.filter { $0.date?.date?.isToday ?? false })
                }
            }
        }
        tokens.append(token)
    }
    
    func showBottomMessage(type: BottomMessage.MessageType, onClicked: @escaping () -> Void) {
        let bottomMessage = BottomMessage.create(messageType: type, onClicked: onClicked)
        view.addSubview(bottomMessage)
        let height: CGFloat = self.view.safeAreaInsets.bottom + 15
        bottomMessage.show(height)
    }
}

extension PredefinedProjectVc {
    enum Mode {
        case today
        case priority
    }
}
