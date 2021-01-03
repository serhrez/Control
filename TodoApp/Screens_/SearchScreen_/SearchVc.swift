//
//  SearchVc.swift
//  TodoApp
//
//  Created by sergey on 28.11.2020.
//

import Foundation
import UIKit
import Material
import RxDataSources
import RxSwift
import AttributedLib
import Typist

class SearchVc: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let bag = DisposeBag()
    private let viewModel: SearchVcVm = .init()
    private let keyboard = Typist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        applySharedNavigationBarAppearance()
        view.backgroundColor = UIColor(named: "TABackground")
        setupSearchBar()
        setupCollectionView()
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                UIView.animate(withDuration: 0.5) {
                    collectionView.snp.remakeConstraints { make in
                        make.bottom.equalToSuperview().offset(-height)
                    }
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                UIView.animate(withDuration: 0.5) {
                    collectionView.snp.remakeConstraints { make in
                        make.bottom.equalToSuperview().offset(-height)
                    }
                }
            }
            .start()
    }
    
    private func setupSearchBar() {
        let searchBar = UISearchBar(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width * 0.72, height: 44))
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = UIColor(named: "TAAltBackground")!
        
        let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClicked))
        cancelButton.tintColor = UIColor.hex("#447BFE")
        cancelButton.setTitleTextAttributes(Attributes().font(.systemFont(ofSize: 16, weight: .bold)).dictionary, for: .normal)
        navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    private func setupCollectionView() {
        view.layout(collectionView).topSafe(20).leadingSafe(13).trailingSafe(13)
        collectionView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
        collectionView.contentInset = .init(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(TaskCellx2.self, forCellWithReuseIdentifier: TaskCellx2.reuseIdentifier)
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<SearchVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            let task = model.task
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCellx2.reuseIdentifier, for: indexPath) as! TaskCellx2
            cell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasOtherTags: task.tags.count >= 2, priority: task.priority, hasChecklist: !task.subtask.isEmpty, isChecked: task.isDone, onSelected: { self.viewModel.onTaskDone(task, isDone: $0) })
            return cell
        }
        viewModel.searchResult
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
        collectionView.delegate = self
    }
    
    @objc func cancelClicked() {
        router.navigationController?.popViewController(animated: true)
    }
    var didDisappear: () -> Void = { }
    deinit { didDisappear() }
}

extension SearchVc: AppNavigationRouterDelegate { }
extension SearchVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.searchResult.value[0].items[indexPath.row].task
        let taskDetailsVc = TaskDetailsVc(viewModel: .init(task: item))
        router.debugPushVc(taskDetailsVc)
    }
}
extension SearchVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: 62)
    }
}

extension SearchVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty { return }
        viewModel.search(searchText)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(searchBar: SearchBar, willClear textField: UITextField, with text: String?) {
        viewModel.clear()
    }
}
