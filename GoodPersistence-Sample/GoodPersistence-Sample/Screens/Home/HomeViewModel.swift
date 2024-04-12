//
//  AboutViewModel.swift
//  GoodPersistence-Sample
//
//  Created by Marek on 09/02/2023.
//

import Combine
import UIKit
import GoodPersistence

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

    private let savedUserDefaultsValue = CurrentValueSubject<String, Never>("")
    private(set) lazy var savedUserDefaultsValuePublisher = savedUserDefaultsValue.eraseToAnyPublisher()
    
    private let savedKeychainValue = CurrentValueSubject<String, Never>("")
    private(set) lazy var savedKeychainValuePublisher = savedKeychainValue.eraseToAnyPublisher()

    // MARK: - Initializer

    init(di: DI, coordinator: Coordinator<AppStep>) {
        self.coordinator = coordinator
        self.di = di

        setupTimer()
        sinkToValue()
        savedUserDefaultsValue.send(di.cacheManager.savedTimeUserDefaults)
        savedKeychainValue.send(di.cacheManager.savedTimeKeychain)
    }

}

// MARK: - Public

extension HomeViewModel {

    func saveToUserDefaults(value: String) {
        di.cacheManager.saveToUserDefaults(value: value)
    }
    
    func saveToKeychain(value: String) {
        di.cacheManager.saveToKeychain(value: value)
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

    func sinkToValue() {
        di.cacheManager.savedTimeUserDefaultsPublisher
            .sink { [weak self] value in self?.savedUserDefaultsValue.send(value) }
            .store(in: &cancellables)
        
        di.cacheManager.savedTimeKeychainPublisher
            .sink(receiveCompletion: { completion in
                if case let .failure(keychainError) = completion {
                    print(keychainError)
                }
            }, receiveValue: { [weak self] value in
                self?.savedKeychainValue.send(value)
            })
            .store(in: &cancellables)
    }

}
