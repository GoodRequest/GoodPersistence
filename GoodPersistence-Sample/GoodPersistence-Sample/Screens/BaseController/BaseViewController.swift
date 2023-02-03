//
//  BaseViewController.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit
import Combine

class BaseViewController<T>: UIViewController {

    let viewModel: T
    var cancellables = Set<AnyCancellable>()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(viewModel: T) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

}
