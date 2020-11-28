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
        view.backgroundColor = .hex("#F6F6F3")
        setupSearchBar()
        setupCollectionView()
        setupKeyboard()
    }
    
    private func setupKeyboard() {
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.height
                UIView.animate(withDuration: 0) {
                    self.view.layout(self.collectionView).bottomSafe(height - self.view.safeAreaInsets.bottom)
                    self.view.layoutIfNeeded()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                view.layout(self.collectionView).bottomSafe()
            }
            .start()
    }
    
    private func setupSearchBar() {
        let searchBar = SearchBar()
        let img = UIImageView(image: UIImage(named: "searchsvg"))
        img.contentMode = .scaleAspectFit
        let imgContainer = UIView()
        imgContainer.layout(img).center().width(18).height(18)
        searchBar.leftViews = [imgContainer]
        searchBar.contentEdgeInsets = .init(top: 0, left: 10, bottom: 0, right: 10)
        searchBar.backgroundColor = .white
        searchBar.layer.cornerRadius = 16
        searchBar.layer.cornerCurve = .continuous
        searchBar.delegate = self
        navigationItem.centerViews = [searchBar]
        navigationItem.backButton.isHidden = true
        let cancelButton = UIButton(type: .system)
        cancelButton.setAttributedTitle("Cancel".at.attributed { attr in
            attr.foreground(color: UIColor.hex("#447BFE")).font(.systemFont(ofSize: 16, weight: .bold))
        }, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelClicked), for: .touchUpInside)
        navigationItem.rightViews = [cancelButton]
        navigationItem.contentViewAlignment = .full
    }
    
    private func setupCollectionView() {
        view.layout(collectionView).topSafe(20).bottomSafe().leadingSafe(13).trailingSafe(13)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.register(TaskCellx2.self, forCellWithReuseIdentifier: TaskCellx2.reuseIdentifier)
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimSection<SearchVcVm.Model>> { [unowned self] (data, collectionView, indexPath, model) -> UICollectionViewCell in
            let task = model.task
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCellx2.reuseIdentifier, for: indexPath) as! TaskCellx2
            cell.configure(text: task.name, date: task.date?.date, tagName: task.tags.first?.name, hasChecklist: !task.subtask.isEmpty, isChecked: task.isDone, onSelected: { self.viewModel.onTaskDone(task, isDone: $0) })
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
}
extension SearchVc: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let model = viewModel.models[indexPath.section].items[indexPath.row]
////        switch model {
////        case .addTag:
////            viewModel.allowAdding()
////        case .addTagEnterName: break
////        case let .tag(tag):
////            print("tag selected: \(tag)")
////            break
////        }
    }
}
extension SearchVc: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.frame.width, height: 62)
    }
}

extension SearchVc: SearchBarDelegate {
    func searchBar(searchBar: SearchBar, didChange textField: UITextField, with text: String?) {
        guard let text = text else { return }
        viewModel.search(text)
    }
    
    func searchBar(searchBar: SearchBar, didClear textField: UITextField, with text: String?) {
        viewModel.clear()
    }
}
