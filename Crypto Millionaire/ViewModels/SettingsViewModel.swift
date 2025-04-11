//
//  SettingsViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 10/04/2025.
//

import Foundation
import Combine


// View model for SettingsView
// Manages user settings and app configuration
class SettingsViewModel: ObservableObject {
    @Published var userBalance: UserBalance?
    @Published var initialBalance: Double = 10000.0
    @Published var darkMode: Bool = false
    @Published var refreshInterval: Int = 5 // minutes
    @Published var showSuccessMessage: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    private let databaseManager = DatabaseManager.shared
    
    init() {
        // Load current user balance
        userBalance = databaseManager.getUserBalance()
        
        // Set default values based on current settings
        if let balance = userBalance {
            initialBalance = balance.initialBalance
        }
        
        // Load system preferences
        darkMode = UserDefaults.standard.bool(forKey: "darkMode")
        refreshInterval = UserDefaults.standard.integer(forKey: "refreshInterval")
        if refreshInterval == 0 {
            refreshInterval = 5 // Default value
        }
    }
    
    
    // Updates user settings
    func saveSettings() {
        // Save dark mode preference
        UserDefaults.standard.set(darkMode, forKey: "darkMode")
        
        // Save refresh interval
        UserDefaults.standard.set(refreshInterval, forKey: "refreshInterval")
        
        // Update initial balance if changed
        if let balance = userBalance, balance.initialBalance != initialBalance {
            var updatedBalance = balance
            updatedBalance.initialBalance = initialBalance
            
            if databaseManager.updateUserBalance(updatedBalance) {
                userBalance = updatedBalance
                successMessage = "Settings saved successfully"
            } else {
                errorMessage = "Failed to update initial balance"
            }
        } else {
            successMessage = "Settings saved successfully"
        }
        
        showSuccessMessage = true
    }
    
    
    // Resets all app data (dangerous operation)
    func resetAllData() -> Bool {
        if databaseManager.resetAllData() {
            // Reload user balance after reset
            userBalance = databaseManager.getUserBalance()
            successMessage = "All data has been reset"
            return true
        } else {
            errorMessage = "Failed to reset app data"
            return false
        }
    }
    
    
    // Returns the current theme mode name
    var themeName: String {
        return darkMode ? "Dark" : "Light"
    }
}
