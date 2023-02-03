//
//  HomeCoordinator.swift
//  GoodPersistence-Sample
//
//  Created by Marek on 10/02/2023.
//

import UIKit

enum HomeStep {

    case goToAbout

}

final class HomeCoordinator: Coordinator<AppStep> {

    private let di: DI

    init(di: DI) {
        self.di = di
        super.init(rootViewController: UINavigationController())
    }

    override func start() -> UIViewController? {
        let homeViewModel = HomeViewModel(di: di, coordinator: self)
        let homeViewController = HomeViewController(viewModel: homeViewModel)

        navigationController?.viewControllers = [homeViewController]

        return rootViewController
    }

    override func navigate(to stepper: AppStep) {
        switch stepper {
        case .home(let homeStep):
            navigate(to: homeStep)

        default:
            break
        }
    }

    func navigate(to step: HomeStep) {
        switch step {
        case .goToAbout:
            let aboutViewController = AboutCoordinator(
                rootViewController: rootViewController
            ).start()

            navigationController?.pushViewController(aboutViewController, animated: true)
        }
    }

}
