//
//  CacheManager.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Foundation
import GoodPersistence

final class CacheManager: CacheManagerType {

    @UserDefaultValue("savedTimeUserDefaults", defaultValue: "")
    var savedTimeUserDefaults: String

    lazy var savedTimeUserDefaultsPublisher = _savedTimeUserDefaults.publisher
        .dropFirst()
        .removeDuplicates()
        .eraseToAnyPublisher()

    @KeychainValue(
        "savedTimeKeychain",
        defaultValue: "",
        accessibility: .whenPasscodeSetThisDeviceOnly,
        authenticationPolicy: [.biometryAny]
    )
    var savedTimeKeychain: String

    lazy var savedTimeKeychainPublisher = _savedTimeKeychain.valuePublisher
        .removeDuplicates()
        .eraseToAnyPublisher()
    
    @KeychainValue("savedNumberKeychain", defaultValue: 0)
    var savedNumberKeychain: Int
    lazy var savedNumber = $savedNumberKeychain
    
    func saveToUserDefaults(value: String) {
        savedTimeUserDefaults = value
    }
    
    func saveToKeychain(value: String) {
        savedTimeKeychain = value
    }

    func resetToDefault() {
        savedTimeUserDefaults = ""
        savedTimeKeychain = ""
    }
}
