//
//  AboutViewModel.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Combine
import Foundation

final class AboutViewModel {

    // MARK: - Variables

    var coordinator: Coordinator<AppStep>

    // MARK: - Initializer

    init(coordinator: Coordinator<AppStep>) {
        self.coordinator = coordinator
    }
}



extension AboutViewModel {

    func openLink(link: String) {
        guard let url = URL(string: link) else { return }

        coordinator.navigate(to: .safari(url))
    }

}
