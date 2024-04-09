//
//  Configuration.swift
//
//
//  Created by Dominik Pethö on 05/04/2024.
//

public final class GoodPersistence {

    /// Used for configuring the GoodPoersistance monitors
    public final class Configuration {

        public static private(set) var monitors: [PersistenceMonitor] = []

        /// Pass monitors to parameters. Each monitor invokes it's appropriate function.
        public static func configure(monitors: [PersistenceMonitor]) {
            Self.monitors = monitors
        }

    }

}
