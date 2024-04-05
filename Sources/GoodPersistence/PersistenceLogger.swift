//
//  File.swift
//  
//
//  Created by Dominik Pethö on 05/04/2024.
//

import Foundation

final class PersistenceLogger {

    static func log(error: Error) {
        GoodPersistence.Configuration.monitors.forEach {
            $0.didReceive($0, error: error)
        }
    }

    static func log(message: String) {
        GoodPersistence.Configuration.monitors.forEach {
            $0.didReceive($0, message: message)
        }
    }

}

