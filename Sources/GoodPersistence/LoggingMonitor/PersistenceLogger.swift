//
//  PersistenceLogger.swift
//
//  Created by Andrej Jasso on 12/04/2024.
//

import Foundation
import OSLog

public protocol PersistanceLogger {

    func log(level: OSLogType, message: String)

}
