//
//  UserManager.swift
//  WatchOS-biltz Watch App
//


import Foundation

class UserManager {
    static let shared = UserManager()
    
    private let defaults = UserDefaults.standard

    private init() {}

    func initializeCredits() {
        let isFirstLaunch = !defaults.bool(forKey: Constants.UserDefaultsKeys.creditsInitialized)
        if isFirstLaunch {
            defaults.set(Constants.Credits.initialCredits, forKey: Constants.UserDefaultsKeys.userCredits)
            defaults.set(true, forKey: Constants.UserDefaultsKeys.creditsInitialized)
        }
    }

    func addCredits(_ credits: Int) {
        let currentCredits = defaults.integer(forKey: Constants.UserDefaultsKeys.userCredits)
        defaults.set(currentCredits + credits, forKey: Constants.UserDefaultsKeys.userCredits)
    }

    func consumeCredit() -> Bool {
        var currentCredits = defaults.integer(forKey: Constants.UserDefaultsKeys.userCredits)
        if currentCredits > 0 {
            currentCredits -= 1
            defaults.set(currentCredits, forKey: Constants.UserDefaultsKeys.userCredits)
            return true
        }
        return false
    }

    func getCurrentCredits() -> Int {
        return defaults.integer(forKey: Constants.UserDefaultsKeys.userCredits)
    }
}
