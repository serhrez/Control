//
//  PlannedVcHeader.swift
//  TodoApp
//
//  Created by sergey on 15.12.2020.
//

import Foundation
import UIKit
import SnapKit
import SwiftDate

class PlannedVcHeader: UICollectionReusableView {
    static let identifier = "plannedvcheader"
    private let bigNumber: UILabel = {
        let label = UILabel()
        label.font = Fonts.heading1
        label.textColor = UIColor(named: "TAHeading")!
        return label
    }()
    private let smallText: UILabel = {
        let label = UILabel()
        label.font = Fonts.heading2
        label.textColor = UIColor(named: "TASubElement")!
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(date: Date) {
        smallText.text = date.toFormat("EEEE")
        bigNumber.text = date.toFormat("dd")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        [bigNumber, smallText].forEach { addSubview($0) }
        bigNumber.snp.makeConstraints { make in
            make.leading.equalTo(15)
            make.bottom.equalTo(-9)
        }
        smallText.snp.makeConstraints { make in
            make.leading.equalTo(bigNumber.snp.trailing).offset(6)
            make.firstBaseline.equalTo(bigNumber.snp.firstBaseline).offset(-2)
        }
    }
}
