//
//  Coordinator.swift
//  GoodPersistence-Sample
//
//  Created by Marek on 10/02/2023.
//

import UIKit
import Combine

class Coordinator<Step> {

    var rootViewController: UIViewController?

    var rootNavigationController: UINavigationController? {
        return rootViewController as? UINavigationController
    }

    var navigationController: UINavigationController? {
        return rootViewController as? UINavigationController
    }

    func start() -> UIViewController? {
        return rootViewController
    }

    init(rootViewController: UIViewController? = nil) {
        self.rootViewController = rootViewController
    }

    func navigate(to stepper: Step) {}

}
