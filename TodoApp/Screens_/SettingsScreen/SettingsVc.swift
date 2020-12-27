//
//  SettingsVc.swift
//  TodoApp
//
//  Created by sergey on 27.12.2020.
//

import Foundation
import UIKit
import Material

class SettingsVc: UIViewController {

    lazy var mainCollectionView = SettingsVcCollectionView(
        items: [
            .init(text: "Premium Features", imageName: "premiumfire", imageWidth: 12, onClick: { [weak self] in
                guard let self = self else { return }
                
            }),
            .init(text: "Archive", imageName: "archive", imageWidth: 20, onClick: { [weak self] in
                guard let self = self else { return }
                self.router.openArchive()
            })
        ])
    lazy var secondaryCollectionView = SettingsVcCollectionView(
        items: [
            .init(text: "Recommend to Friends", imageName: "recommendheart", imageWidth: 16.35, onClick: { [weak self] in
                guard let self = self else { return }
                
            }),
            .init(text: "Feedback & Suggestions", imageName: "feedback", imageWidth: 18, onClick: { [weak self] in
                guard let self = self else { return }
                
            })
        ])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hex("#f6f6f3")
        applySharedNavigationBarAppearance()
        title = "Settings"
        
        view.layout(mainCollectionView).topSafe(15).leading(13).trailing(13).bottomSafe()
        mainCollectionView.collectionView.isScrollEnabled = false
        view.layout(secondaryCollectionView).bottomSafe(15).leading(13).trailing(13).height(133)
        secondaryCollectionView.collectionView.isScrollEnabled = false
//        collec
//        let collectionView = UIColle
    }
}

