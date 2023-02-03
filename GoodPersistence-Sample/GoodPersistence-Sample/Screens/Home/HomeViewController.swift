//
//  AboutViewController.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit
import Combine

final class HomeViewController: BaseViewController<HomeViewModel>  {

    private let counterValueLabel: UILabel = {
        let counterValueLabel = MultiLineLabel.create(
            font: .systemFont(ofSize: 64, weight: .heavy),
            alignment: .center
        )
        counterValueLabel.translatesAutoresizingMaskIntoConstraints = false

        return counterValueLabel
    }()

    private let savedValueLabel: MultiLineLabel = {
        let counterValueLabel = MultiLineLabel.create(
            font: .systemFont(ofSize: 32, weight: .heavy),
            alignment: .center
        )
        counterValueLabel.translatesAutoresizingMaskIntoConstraints = false
        counterValueLabel.isHidden = true

        return counterValueLabel
    }()

    private let saveButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(Constants.Texts.Home.save, for: .normal)
        button.updateActivityIndicatorColor(color: .black)

        return button
    }()

    private let resetButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(Constants.Texts.Home.reset, for: .normal)

        return button
    }()

    private let aboutAppButton: ActionButton = {
        let button = ActionButton()
        button.setTitle(Constants.Texts.Home.aboutApp, for: .normal)

        return button
    }()

    private let bottomStackView: UIStackView = {
        let bottomStackView = UIStackView()
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 16

        return bottomStackView
    }()


}

// MARK: - Lifecycle

extension HomeViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        bindState(reactor: viewModel)
        bindActions(reactor: viewModel)
    }

}

// MARK: - Setup

extension HomeViewController {

    func setupLayout() {
        view.backgroundColor = UIColor(named: "background")
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Constants.Texts.Home.title

        [saveButton, resetButton, aboutAppButton].forEach { bottomStackView.addArrangedSubview($0) }
        [bottomStackView, counterValueLabel].forEach {view.addSubview($0) }

        view.addSubview(savedValueLabel)
        setupConstraints()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            counterValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterValueLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            savedValueLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            savedValueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            bottomStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            bottomStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


}

// MARK: - Combine

extension HomeViewController {

    func bindState(reactor: HomeViewModel) {
        reactor.sourcePublisher
            .map { DateFormatterHelper.shared.formatDateToString(date: $0, dateFormat: .hhmmss) }
            .removeDuplicates()
            .assign(to: \.text, on: counterValueLabel, ownership: .weak)
            .store(in: &cancellables)

        reactor.savedValuePublisher
            .removeDuplicates()
            .sink { [weak self] in self?.handle(savedValue: $0) }
            .store(in: &cancellables)
    }

    func bindActions(reactor: HomeViewModel) {
        saveButton.publisher(for: .touchUpInside)
            .sink { [unowned self] in
                guard let timerValue = self.counterValueLabel.text else { return }

                reactor.saveToCache(value: timerValue) }
            .store(in: &cancellables)

        resetButton.publisher(for: .touchUpInside)
            .sink { reactor.resetCache() }
            .store(in: &cancellables)


        aboutAppButton.publisher(for: .touchUpInside)
            .sink { reactor.goToAbout() }
            .store(in: &cancellables)
    }

}

// MARK: - Private

extension HomeViewController {

    func handle(savedValue: String) {
        savedValueLabel.isHidden = savedValue.isEmpty
        savedValueLabel.text =  [Constants.Texts.Home.savedTime, savedValue].joined()
    }

}
