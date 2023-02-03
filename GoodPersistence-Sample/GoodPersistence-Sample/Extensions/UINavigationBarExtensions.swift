//
//  UINavigationBarExtensions.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit

extension UINavigationBar {

    static func configureAppearance() {
        let appearance = self.appearance()
        appearance.tintColor = .black
        appearance.prefersLargeTitles = true
    }

}
