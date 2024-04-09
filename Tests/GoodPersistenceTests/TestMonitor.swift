//
//  File.swift
//  
//
//  Created by Dominik Pethö on 05/04/2024.
//
import GoodPersistence

final class TestMonitor: PersistenceMonitor {

    var error: Error?
    var message: String?

    func didReceive(_ monitor: PersistenceMonitor, error: Error) {
        debugPrint(error)
        self.error = error
    }

    func didReceive(_ monitor: PersistenceMonitor, message: String) {
        debugPrint(message)
        self.message = message
    }

}
