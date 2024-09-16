//
//  Constants.swift
//  WatchOS-biltz Watch App


import Foundation

struct Constants {
    
    static let kTermsConditions = "https://apps.blitzinteractive.io/terms-and-conditions/"
    static let kPrivacyPolicy = "https://apps.blitzinteractive.io/privacy-policy/"
    
    struct UserDefaultsKeys {
        static let creditsInitialized = "creditsInitialized"
        static let userCredits = "userCredits"
        static let appVersion = "appVersion"
    }

    struct IAPProductIdentifiers {
        static let credits120 = "com.wristsearch.app.credits.120"
        static let credits200 = "com.wristsearch.app.credits.200"
        static let credits300 = "com.wristsearch.app.credits.300"
    }

    struct Credits {
        static let initialCredits = 150
        static let creditsFor120Purchase = 120
        static let creditsFor200Purchase = 200
        static let creditsFor300Purchase = 300
    }
}
