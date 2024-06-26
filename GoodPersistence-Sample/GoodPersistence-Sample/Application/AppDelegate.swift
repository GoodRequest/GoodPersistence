//
//  AppDelegate.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit
import GoodPersistence
import GoodLogger

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()

        UINavigationBar.configureAppearance()

        GoodPersistence.Configuration.configure(monitors: [LoggingPersistenceMonitor(logger: OSLogLogger())])
        AppCoordinator(window: window, di: DI()).start()
        
        return true
    }

}

