//
//  GoodPersistence.swift
//
//  Created by Dominik Pethö on 05/04/2024.
//

public final class GoodPersistence {

    /// Used for configuring the GoodPersistence monitors
    public final class Configuration {

        public static private(set) var monitors: [PersistenceMonitor] = []

        /// Pass monitors to parameters. Each monitor invokes it's appropriate function.
        public static func configure(monitors: [PersistenceMonitor]) {
            Self.monitors = monitors
        }

    }

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
