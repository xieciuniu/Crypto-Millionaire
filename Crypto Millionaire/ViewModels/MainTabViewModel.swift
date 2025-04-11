//
//  MainTabViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 10/04/2025.
//

import Foundation
import Combine


// View model for MainTabView
// Manages global app state and data refreshing

class MainTabViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var userBalance: UserBalance?
    @Published var refreshTimerActive: Bool = true
    
    private var refreshTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let databaseManager = DatabaseManager.shared
    
    // Child view models - can be used to refresh data across tabs
    let cryptocurrencyListViewModel = CryptocurrencyListViewModel()
    let portfolioViewModel = PortfolioViewModel()
    let rankingViewModel = RankingViewModel()
    
    init() {
        // Load user balance
        loadUserBalance()
        
        // Setup auto-refresh timer
        setupRefreshTimer()
        
        // Listen for changes to the refresh interval
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.setupRefreshTimer()
            }
            .store(in: &cancellables)
    }
    
    
    // Loads user balance data
    
    func loadUserBalance() {
        userBalance = databaseManager.getUserBalance()
    }
    
    
    // Sets up the refresh timer based on user settings
    
    private func setupRefreshTimer() {
        // Invalidate existing timer
        refreshTimer?.invalidate()
        
        // Get refresh interval from settings
        let interval = UserDefaults.standard.integer(forKey: "refreshInterval")
        let refreshMinutes = interval > 0 ? interval : 5 // Default to 5 minutes
        
        // Create new timer only if auto-refresh is enabled
        if refreshTimerActive {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshMinutes * 60), repeats: true) { [weak self] _ in
                self?.refreshAllData()
            }
        }
    }
    
    
    // Refreshes data across all tabs
    
    func refreshAllData() {
        // Refresh data based on the currently selected tab
        switch selectedTab {
        case 0: // Market tab
            cryptocurrencyListViewModel.refreshData()
        case 1: // Portfolio tab
            portfolioViewModel.refreshData()
        case 2: // Ranking tab
            rankingViewModel.refreshData()
        default:
            break
        }
        
        // Always refresh user balance
        loadUserBalance()
    }
    
    
    // Toggles automatic data refreshing
    
    func toggleAutoRefresh() {
        refreshTimerActive.toggle()
        setupRefreshTimer()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}
