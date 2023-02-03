//
//  AppCoordinator.swift
//  GoodPersistence-Sample
//
//  Created by Marek on 10/02/2023.
//

import UIKit

enum AppStep {

    case home(HomeStep)
    case safari(URL)

}

final class AppCoordinator: Coordinator<AppStep> {

    private let window: UIWindow?
    private let di: DI

    init(window: UIWindow?, di: DI) {
        self.window = window
        self.di = di
    }

    @discardableResult
    override func start() -> UIViewController? {
        window?.rootViewController = HomeCoordinator(di: di).start()
        window?.makeKeyAndVisible()

        return nil
    }

}
