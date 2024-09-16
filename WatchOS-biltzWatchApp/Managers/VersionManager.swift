//
//  VersionManager.swift
//  WatchOS-biltz Watch App
//
//  Created by Sheraz Hussain on 02/09/2024.
//

import Foundation

class VersionManager {
    static let shared = VersionManager()
    
    private let defaults = UserDefaults.standard

    private init() {}

    func handleVersionUpdate() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let storedVersion = defaults.string(forKey: Constants.UserDefaultsKeys.appVersion)

        if storedVersion != currentVersion {
            UserManager.shared.addCredits(Constants.Credits.initialCredits)
            defaults.set(currentVersion, forKey: Constants.UserDefaultsKeys.appVersion)
        }
    }
}

