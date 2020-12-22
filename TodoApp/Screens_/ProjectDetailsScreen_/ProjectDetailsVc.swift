//
//  ProjectDetailsVc.swift
//  TodoApp
//
//  Created by sergey on 11.11.2020.
//

import Foundation
import UIKit
import Material
import Typist

class ProjectDetailsVc: UIViewController {
    private var didAppear: Bool = false
    private let keyboard = Typist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hex("#F6F6F3")
        topViewSetup()
        toolbarViewSetup()
        projectStartedViewSetup()
        projectNewTaskViewSetup()
        setupKeyboard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        self.newFormView.didAppear()
        self.view.layoutSubviews()
        self.view.layout(tasksToolbar).bottomSafe(30)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.3) {
            self.top.addShadowFromOutside()
            self.view.layoutSubviews()
        }
    }
    
    func setupKeyboard() {
        var previousHeight: CGFloat?
        keyboard
            .on(event: .willChangeFrame) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .on(event: .willHide) { [unowned self] options in
                let height = options.endFrame.intersection(view.bounds).height
                guard previousHeight != height else { return }
                previousHeight = height
                newFormView.snp.remakeConstraints { make in
                    make.bottom.equalTo(-height)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutSubviews()
                }
            }
            .start()

    }
    
//    func changeScreenState() {
//        
//    }
//    
    // MARK: - TOP VIEW
    private func topViewSetup() {
        view.layout(top).leading(13).trailing(13).topSafe()
        top.shouldLayoutSubviews = view.layoutSubviews
        newFormView.shouldLayoutSubviews = view.layoutSubviews
    }
    lazy var top = ProjectDetailsTop(
        color: .hex("#FF9900"),
        projectName: "fewfgw",
        projectDescription: "gewgqw",
        icon: .text("🚒"),
        onProjectNameChanged: projectNameChanged,
        onProjectDescriptionChanged: projectDescriptionChanged,
        colorSelection: colorSelection,
        iconSelected: iconClicked,
        shouldAnimate: { [unowned self] in self.didAppear })
    private func projectNameChanged(_ newName: String) {
        
    }
    private func projectDescriptionChanged(_ newDescription: String) {
        
    }
    private func colorSelection(_ sourceView: UIView, _ selectedColor: UIColor) {
        let colorPicker = ColorPicker(viewSource: sourceView, selectedColor: selectedColor, onColorSelection: { print($0) })
        colorPicker.shouldPurposelyAnimateViewBackgroundColor = true
        addChildPresent(colorPicker)
        colorPicker.shouldDismiss = { [weak colorPicker] in
            colorPicker?.addChildDismiss()
        }
    }
    private func iconClicked() {
        
    }
    
    // MARK: - Toolbar VIEW
    private func toolbarViewSetup() {
        view.layout(tasksToolbar).leadingSafe(13).trailingSafe(13).bottomSafe(-AllTasksToolbar.estimatedHeight)
        tasksToolbar.onClick = { print("taskstoolbar clicked") }
    }
    private lazy var tasksToolbar = AllTasksToolbar()
    
    // MARK: - ProjectStarted VIEW
    private func projectStartedViewSetup() {
        view.layout(projectStartedView).center().leading(47).trailing(47)
    }
    private lazy var projectStartedView = ProjectStartedView()
    
    // MARK: - ProjectNewTaskForm VIEW
    private func projectNewTaskViewSetup() {
        view.layout(newFormView).leading().trailing()
        newFormView.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom)
        }
    }
    private lazy var newFormView = ProjectNewTaskForm(
        onCalendarClicked: { _ in },
        onTagClicked: { _ in },
        onPriorityClicked: { _ in },
        onTagPlusClicked: { },
        shouldAnimate: { [unowned self] in self.didAppear },
        shouldCreateTask: { print("newTask: \($0)") })
    
    var didDisappear: () -> Void = { }
    deinit {
        didDisappear()
    }
}

extension ProjectDetailsVc {
    enum ScreenState {
        case empty
    }
}

extension ProjectDetailsVc: AppNavigationRouterDelegate { }
