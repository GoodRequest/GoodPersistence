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
        logger?.log(message: error.localizedDescription, level: .error, privacy: .auto)
    }

    public func didReceive(_ monitor: any PersistenceMonitor, message: String) {
        logger?.log(message: message, level: .info, privacy: .auto)
    }

}
