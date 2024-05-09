//
//  TestMonitor.swift
//
//  Created by Dominik Pethö on 05/04/2024.
//

import GoodPersistence

final class TestMonitor: PersistenceMonitor {

    var errors: [Error] = []
    var messages: [String] = []

    func didReceive(_ monitor: PersistenceMonitor, error: Error) {
        debugPrint(error)
        self.errors.append(error)
    }

    func didReceive(_ monitor: PersistenceMonitor, message: String) {
        debugPrint(message)
        self.messages.append(message)
    }

}
