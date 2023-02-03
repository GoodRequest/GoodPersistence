//
//  AboutCoordinator.swift
//  GoodPersistence-Sample
//
//  Created by Marek on 10/02/2023.
//

import UIKit
import SafariServices

class AboutCoordinator: Coordinator<AppStep> {

    override func start() -> AboutViewController {

        let aboutViewModel = AboutViewModel(coordinator: self)
        let aboutViewController = AboutViewController(viewModel: aboutViewModel)

        if rootViewController == nil {
            rootViewController = aboutViewController
        }

        return aboutViewController
    }

    override func navigate(to stepper: AppStep) {
        switch stepper {
        case .safari(let url):
            let safariViewController = SFSafariViewController(url: url)
            navigationController?.present(safariViewController, animated: true)

        case .home(_):
            break
        }
    }

}
