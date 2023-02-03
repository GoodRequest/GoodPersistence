//
//  DependencyContainer.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Foundation

protocol WithCacheManager: AnyObject {

    var cacheManager: CacheManagerType { get }

}

final class DependencyContainer: WithCacheManager {

    lazy var cacheManager: CacheManagerType = CacheManager()

}
