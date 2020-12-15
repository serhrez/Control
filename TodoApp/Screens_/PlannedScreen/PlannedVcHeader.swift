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
        label.font = .systemFont(ofSize: 46, weight: .bold)
        label.textColor = .hex("#242424")
        return label
    }()
    private let smallText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .hex("#a4a4a4")
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
