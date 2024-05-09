//
//  PersistenceMonitor.swift
//
//  Created by Dominik Pethö on 05/04/2024.
//

/// Extend function to receive error or message from GoodPersistance library
public protocol PersistenceMonitor {

    func didReceive(_ monitor: PersistenceMonitor, error: Error)
    func didReceive(_ monitor: PersistenceMonitor, message: String)

}

/// Default implementation of optional protocol functions
public extension PersistenceMonitor {

    func didReceive(_ monitor: PersistenceMonitor, message: String) {}

}
