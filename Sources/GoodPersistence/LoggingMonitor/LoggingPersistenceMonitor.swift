//
//  LoggingPersistenceMonitor.swift
//
//  Created by Andrej Jasso on 12/04/2024.
//

import Foundation

public final class LoggingPersistenceMonitor: PersistenceMonitor {

    private var logger: (any PersistanceLogger)?

    public init(logger: (any PersistanceLogger)?) {
        self.logger = logger
    }

    public func didReceive(_ monitor: any PersistenceMonitor, error: any Error) {
        logger?.log(level: .error, message: error.localizedDescription)
    }

    public func didReceive(_ monitor: any PersistenceMonitor, message: String) {
        logger?.log(level: .info, message: message)
    }

}
