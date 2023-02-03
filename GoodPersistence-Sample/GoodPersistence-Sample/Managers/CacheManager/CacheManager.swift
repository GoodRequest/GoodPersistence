//
//  CacheManager.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Foundation
import GoodPersistence

final class CacheManager: CacheManagerType {

    @UserDefaultValue("savedTime", defaultValue: "")
    var savedTime: String

    lazy var savedTimePublisher = _savedTime.publisher
        .dropFirst()
        .removeDuplicates()
        .eraseToAnyPublisher()


    func save(value: String) {
        savedTime = value
    }

    func resetToDefault() {
        savedTime = ""
    }
}
