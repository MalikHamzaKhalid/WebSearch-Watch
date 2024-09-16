//
//  UserManager.swift
//  WatchOS-biltz Watch App
//


import Foundation

class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    private let creditsKey = "userCredits"
    
    // Function to update and save credits after usage
    func initCredits(by amount: Int) {
        KeychainManager.shared.save("\(amount)", forKey: creditsKey)
    }
    
    // Function to initialize or get current credits
    func getCurrentCredits() -> Int {
        if let savedCredits = KeychainManager.shared.getValue(forKey: creditsKey),
           let currentCredits = Int(savedCredits) {
            // Return saved credits from Keychain
            return currentCredits
        } else {
            // First-time launch or no credits found, give 150 credits
            let initialCredits = 150
            initCredits(by: initialCredits)
            return initialCredits
        }
    }
    
    // Function to update and save credits after usage
    func updateCredits() {
        var currentCredits = getCurrentCredits()
        currentCredits -= 1
        KeychainManager.shared.save("\(currentCredits)", forKey: creditsKey)
    }
    
    // Function to check if the user has used their credits
    func hasCredits() -> Bool {
        let currentCredits = getCurrentCredits()
        return currentCredits > 0
    }
}
