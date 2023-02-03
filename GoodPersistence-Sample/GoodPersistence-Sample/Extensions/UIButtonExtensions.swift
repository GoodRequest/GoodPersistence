//
//  UIButtonExtensions.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit

extension UIButton {

    func animate(isHighlighted: Bool) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.transform = isHighlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            },
            completion: nil
        )
    }

}
