//
//  OSLogLogger.swift
//
//  Created by Matus Klasovity on 30/01/2024.
//

import Foundation
import OSLog

@available(iOS 14, *)
public final class OSLogLogger: PersistanceLogger {

    private let logger = Logger(subsystem: "OSLogSessionLogger", category: "Networking")

    public init() {}

    public func log(level: OSLogType, message: String) {
        logger.log(level: level, "\(message)")
    }

}
