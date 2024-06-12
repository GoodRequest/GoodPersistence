//
//  LoggingPersistenceMonitor.swift
//
//  Created by Andrej Jasso on 12/04/2024.
//

import Foundation
import GoodLogger

public final class LoggingPersistenceMonitor: PersistenceMonitor {

    private var logger: (any GoodLogger)?

    public init(logger: (any GoodLogger)?) {
        self.logger = logger
    }

    public func didReceive(_ monitor: any PersistenceMonitor, error: any Error) {
        logger?.log(level: .error, message: error.localizedDescription, privacy: .auto)
    }

    public func didReceive(_ monitor: any PersistenceMonitor, message: String) {
        logger?.log(level: .info, message: message, privacy: .auto)
    }

}
