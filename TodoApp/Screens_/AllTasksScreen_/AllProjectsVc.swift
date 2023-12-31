//
//  ViewController.swift
//  TodoApp
//
//  Created by sergey on 07.11.2020.
//

import UIKit
import Motion
import Material
import RxSwift
import RxCocoa
import PopMenu
import Typist
import SwiftDate

class AllProjectsVc: UIViewController {
    let viewModel: AllProjectsVcVM = AllProjectsVcVM()
    let tableView = UITableView()
    var pushTransition = SlidePushTransition()
    private var searchVcScreenOpened: Bool = false
    private var didAppear = false

    lazy var tasksToolbar: AllTasksToolbar = {
        let view = AllTasksToolbar(frame: .zero)
        view.onClick = { [weak self] in
            let project = RealmProvider.main.realm.objects(RlmProject.self).first(where: { $0.id == Constants.inboxId })!
            self?.router.openProjectDetails(project: project, state: .startAddTask, isInbox: true)
        }
        return view
    }()
    private let keyboard = Typist()
    private lazy var menuButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(menuButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()

    private lazy var searchButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "search"), style: .done, target: self, action: #selector(searchButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()

    private lazy var actionsButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "dots"), style: .done, target: self, action: #selector(actionsButtonClicked))
        button.tintColor = UIColor(named: "TAHeading")!
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupSettingsPushVc()
        if !UserDefaultsWrapper.shared.didOnboard {
            let onboardingVc = OnboardingVc.getOnboardingNavigation { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                UserDefaultsWrapper.shared.didOnboard = true
            } onPremiumVc: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
                UserDefaultsWrapper.shared.didOnboard = true
            }
            onboardingVc.modalPresentationStyle = .overFullScreen
            
            present(onboardingVc, animated: false, completion: nil)
        }
        // In case something bad happened. Maybe manually violated etc.
        if !(RealmProvider.main.realm.objects(RlmProject.self).contains { $0.id == Constants.inboxId }) {
            let inboxProject = RlmProject(name: "Inbox", icon: .assetImage(name: "inboximg", tintHex: "#571cff"), notes: "", color: .hex("#571cff"), date: Date())
            inboxProject.id = Constants.inboxId
            RealmProvider.main.safeWrite {
                RealmProvider.main.realm.add(inboxProject)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let windowScene = self.view.window?.windowScene {
                StoreKitHelper.maybeDisplayStoreKit(windowScene: windowScene)
            }
        }

    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(named: "TABackground")
        setupNavigationBar()
        setupTableView()
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottom(-AllTasksToolbar.estimatedHeight)
    }
    
    private func setupSettingsPushVc() {
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(didPan))
        edgeGesture.edges = .left
        view.addGestureRecognizer(edgeGesture)
    }
    
    @objc func didPan(gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            pushTransition.isInteractive = true
            navigationController?.pushViewController(SettingsVc(), animated: true)
        case .ended, .cancelled:
            pushTransition.isInteractive = false
        default: break
        }
        pushTransition.handlePan(gesture)
    }
    
    func setupTableView() {
        view.layout(tableView).topSafe().bottom().leadingSafe(13).trailingSafe(13)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(ProjectViewCell.self, forCellReuseIdentifier: ProjectViewCell.reuseIdentifier)
        tableView.register(AddProjectCell.self, forCellReuseIdentifier: AddProjectCell.reuseIdentifier)
        viewModel.initialValues = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.tableUpdates = { [weak self] in
            self?.tableView.reloadData()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 0, left: 0, bottom: 110, right: 0)
        tableView.showsVerticalScrollIndicator = false
        view.layout(gradientView).bottom().leading().trailing().height(216)
    }
    private let gradientView = GradientView()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.layout(tasksToolbar).bottomSafe(Constants.vcMinBottomPadding)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) { [weak self] in
            self?.view.layoutSubviews()
        }
        searchVcScreenOpened = false
        didAppear = true
    }
    
    private func setupNavigationBar() {
        applySharedNavigationBarAppearance(addBackButton: false)
        title = Date().toFormat("E") + ", \(Date().toFormat("d MMMM"))"
        
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItems = [actionsButton, searchButton]
    }
    
    @objc private func searchButtonClicked() {
        router.openSearch()
    }
    
    @objc private func menuButtonClicked() {
        router.openSettings()
    }
    
    // MARK: - POPUP
    @objc private func actionsButtonClicked() {
        let actions: [PopuptodoAction] = [
            PopuptodoAction(title: "Open Tags".localizable(), image: UIImage(named: "tag"), didSelect: { [weak self] action in
                self?.openTags(action: action)
            })
        ]
        PopMenuAppearance.appCustomizeActions(actions: actions)
        let popMenu = PopMenuViewController(sourceView: actionsButton, actions: actions)
        popMenu.appearance = .appAppearance
        
        present(popMenu, animated: true)
    }
    
    func openTags(action: PopMenuAction) {
        dismiss(animated: true, completion: nil)
        router.openAllTags(mode: .show)
    }
}

extension AllProjectsVc: UITableViewDataSource {
    
    func vmIndex(for indexPath: IndexPath) -> Int {
        indexPath.section
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 0.011160714285714 * UIScreen.main.bounds.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.displayVersion2 ? 62 : 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = vmIndex(for: indexPath)
        let model = viewModel.models[index]
        switch model {
        case .addProject:
            let addCell = tableView.dequeueReusableCell(withIdentifier: AddProjectCell.reuseIdentifier, for: indexPath) as! AddProjectCell
            addCell.selectionStyle = .none
            return addCell
        case let .project(project), let .inboxProject(project):
            let projectCell = tableView.dequeueReusableCell(withIdentifier: ProjectViewCell.reuseIdentifier, for: indexPath) as! ProjectViewCell
            let progress = viewModel.getProgress(for: project)
            let isInbox = project.id == Constants.inboxId
            projectCell.configure(icon: project.icon, name: !isInbox ? project.name : "Inbox".localizable(), progress: CGFloat(progress), tasksCount: project.tasks.count, color: project.color, iconFontSize: isInbox ? 22 : nil)
            projectCell.selectionStyle = .none
            return projectCell
        case let .planned(project), let .priority(project), let .today(project):
            let projectCell = tableView.dequeueReusableCell(withIdentifier: ProjectViewCell.reuseIdentifier, for: indexPath) as! ProjectViewCell
            projectCell.configure(icon: project.icon, name: project.name, progress: CGFloat(project.progress), tasksCount: project.tasksCount, color: project.color, iconFontSize: project.iconFontSize)
            projectCell.selectionStyle = .none
            return projectCell
        }
    }
}

extension AllProjectsVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = vmIndex(for: indexPath)
        let model = viewModel.models[index]
        switch model {
        case .addProject:
            router.openAddProject()
        case let .project(project):
            router.openProjectDetails(project: project, state: .emptyOrList)
        case let .inboxProject(project):
            router.openProjectDetails(project: project, state: .emptyOrList, isInbox: true)
        case .planned(_):
            router.openPlanned()
        case .priority(_):
            router.openPredefinedProject(mode: .priority)
        case .today(_):
            router.openPredefinedProject(mode: .today)
        }
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard didAppear else { return }
////        if scrollView.contentOffset.y <= -70 {
////            scrollView.contentOffset = .init(x: 0, y: -70)
////        }
//        if scrollView.contentOffset.y <= -70 && !searchVcScreenOpened {
//            searchVcScreenOpened = true
//            router.openSearch()
//        }
//    }
}

extension AllProjectsVc: TATransitionProvider {
    func pushTransitioning(to vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if vc is SettingsVc {
            return pushTransition
        }
        if vc is SearchVc {
            return FadePushTransition(duration: TimeInterval(UINavigationController.hideShowBarDuration))
        }

        return nil
    }
    
    func popTransitioning(from vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
    func interactionController(for animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return pushTransition.isInteractive ? pushTransition : nil
    }
}
