//
//  AppDelegate.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import UIKit
import GoodPersistence
import GoodLogger

struct SamplePersistenceMonitor: PersistenceMonitor {
    
    func didReceive(_ monitor: any PersistenceMonitor, error: any Error) {
        print("Error received: \(error.localizedDescription)")
    }
    
    func didReceive(_ monitor: any PersistenceMonitor, message: String) {
        print("Message received: \(message)")
    }
    
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()

        UINavigationBar.configureAppearance()

        GoodPersistence.Configuration.configure(monitors: [SamplePersistenceMonitor()])
        AppCoordinator(window: window, di: DI()).start()
        
        return true
    }

}

