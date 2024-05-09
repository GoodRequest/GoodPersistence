//
//  CacheManagerType.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Combine
import GoodPersistence

protocol CacheManagerType: AnyObject {

    var savedTimeUserDefaults: String { get }

    var savedTimeUserDefaultsPublisher: AnyPublisher<String, Never> { get }
    
    var savedTimeKeychain: String { get }

    var savedTimeKeychainPublisher: AnyPublisher<String, Never> { get }

    var savedNumberKeychain: Int { get set }
    
    func saveToUserDefaults(value: String)
    func saveToKeychain(value: String)
    func resetToDefault()
    
}
