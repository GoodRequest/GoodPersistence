//
//  MultiLineLabel.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit

final class MultiLineLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)

        textAlignment = .center
        numberOfLines = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func create(
        text: String? = nil,
        font: UIFont? = nil,
        alignment: NSTextAlignment = .left
    ) -> MultiLineLabel {
        let label = MultiLineLabel()
        label.text = text
        label.font = font
        label.textAlignment = alignment

        return label
    }

}
