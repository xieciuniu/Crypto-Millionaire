//
//  RankingViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation


// View model for RankingView
// Manages best trades data
class RankingViewModel: ObservableObject {
    @Published var bestTrades: [BestTrade] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let databaseManager = DatabaseManager.shared
    
    init() {
        loadBestTrades()
    }
    
    
    // Loads best trades from database
    func loadBestTrades() {
        isLoading = true
        errorMessage = nil
        
        bestTrades = databaseManager.getBestTrades()
        isLoading = false
    }
    
    
    // Refreshes best trades data
    func refreshData() {
        loadBestTrades()
    }
}
