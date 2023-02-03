//
//  AboutViewModel.swift
//  GoodPersistence-Sample
//
//  Created by Marek on 09/02/2023.
//

import Combine
import UIKit

final class HomeViewModel {

    // MARK: - TypeAliases

    typealias DI = WithCacheManager

    // MARK: - Constants

    private let di: DI
    private let coordinator: Coordinator<AppStep>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Combine

    private let sourceSubject = PassthroughSubject<Date, Never>()
    private(set) lazy var sourcePublisher = sourceSubject.eraseToAnyPublisher()

    private let savedValue = CurrentValueSubject<String, Never>("")
    private(set) lazy var savedValuePublisher = savedValue.eraseToAnyPublisher()

    // MARK: - Initializer

    init(di: DI, coordinator: Coordinator<AppStep>) {
        self.coordinator = coordinator
        self.di = di

        setupTimer()
        sinkToCachedValue()
        savedValue.send(di.cacheManager.savedTime)
    }

}

// MARK: - Public

extension HomeViewModel {

    func saveToCache(value: String) {
        di.cacheManager.save(value: value)
    }

    func resetCache() {
        di.cacheManager.resetToDefault()
    }

    func goToAbout() {
        coordinator.navigate(to: .home(.goToAbout))
    }

}

// MARK: - Private

private extension HomeViewModel {

    func setupTimer() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .subscribe(sourceSubject)
            .store(in: &cancellables)
    }

    func sinkToCachedValue() {
        di.cacheManager.savedTimePublisher
            .sink { [weak self] value in self?.savedValue.send(value) }
            .store(in: &cancellables)
    }

}
