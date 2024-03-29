//
//  Constants.swift
//  GoodPersistence-Sample
//
//  Created by GoodRequest on 09/02/2023.
//

import Foundation

struct Constants {

    struct Links {

        static let documentation = "https://goodrequest.github.io/GoodPersistence/documentation/goodpersistence/"
        static let aboutUs = "https://www.goodrequest.com/"

    }

    struct App {

        static let name = "Good Persistence - Sample"
        static let developer = "GoodRequest"
        static let description = "This is a sample App demonstrating usage of GoodPersistence package"

    }

    struct Texts {

        struct About {

            static let title = "About"
            static let aboutUs = "About us"
            static let documentation = "Show documentation"

        }

        struct Home {

            static let title = "Time"
            static let saveToUserDefaults = "Save the time to UserDefaults"
            static let saveToKeychain = "Save the time to KeyChain"
            static let reset = "Reset cache"
            static let aboutApp = "About app"
            static let userDefaultsTime = "UserDefaults saved time:\n"
            static let keychainTime = "Keychain saved time:\n"

        }

    }
}
