//
//  CacheManagerType.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Combine

protocol CacheManagerType: AnyObject {

    var savedTime: String { get }

    var savedTimePublisher: AnyPublisher<String, Never> { get }

    func save(value: String)
    func resetToDefault()
    
}
