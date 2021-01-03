//
//  TagDetailVc.swift
//  TodoApp
//
//  Created by sergey on 27.11.2020.
//

import Foundation
import Material
import UIKit
import RxSwift
import RxDataSources

class TagDetailVc: UIViewController {
    private let bag = DisposeBag()
    let viewModel: TagDetailVcVm
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    init(viewModel: TagDetailVcVm) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        applySharedNavigationBarAppearance()
        title = "Tag: \(viewModel.tag.name)"
        view.backgroundColor = UIColor(named: "TABackground")
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        view.layout(collectionView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(TaskCellx2.self, forCellWithReuseIdentifier: TaskCellx2.reuseIdentifier)
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<TagDetailVcVm.Model>> { [weak self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            let task = model.task
            let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCellx2.reuseIdentifier, for: indexPath) as! TaskCellx2
            tagCell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasOtherTags: task.tags.count >= 2, priority: task.priority, hasChecklist: !task.subtask.isEmpty, isChecked: task.isDone, onSelected: { self?.viewModel.taskSelected(task, isDone: $0)
            })
            return tagCell
        }
        viewModel.tasks
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.delegate = self
    }
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension TagDetailVc: AppNavigationRouterDelegate { }

extension TagDetailVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: 55)
    }
}

extension TagDetailVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.tasks.value[0].items[indexPath.row]
        let taskDetails = TaskDetailsVc(viewModel: .init(task: item.task))
        router.debugPushVc(taskDetails)
    }
}
