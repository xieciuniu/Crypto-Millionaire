//
//  PortfolioViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import Combine


// View model for PortfolioView
// Manages user's portfolio data and operations
class PortfolioViewModel: ObservableObject {
    @Published var portfolioItems: [PortfolioItemViewModel] = []
    @Published var totalValue: Double = 0
    @Published var totalProfitLoss: Double = 0
    @Published var profitLossPercentage: Double = 0
    @Published var userBalance: UserBalance?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let coinGeckoService: CoinGeckoService
    private let databaseManager = DatabaseManager.shared
    
    init(apiKey: String = ApiConfig.coinGeckoApiKey) {
        self.coinGeckoService = CoinGeckoService(apiKey: apiKey)
        loadPortfolio()
    }
    
    
    // Loads user's portfolio data
    
    func loadPortfolio() {
        isLoading = true
        errorMessage = nil
        
        // Get user balance
        userBalance = databaseManager.getUserBalance()
        
        // Get portfolio items from database
        let dbPortfolioItems = databaseManager.getPortfolio()
        
        // If portfolio is empty, finish loading
        if dbPortfolioItems.isEmpty {
            isLoading = false
            portfolioItems = []
            totalValue = 0
            totalProfitLoss = 0
            profitLossPercentage = 0
            return
        }
        
        // Get current cryptocurrency prices to update portfolio values
        coinGeckoService.getCoins()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to load current prices: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] coins in
                // Process each portfolio item
                var updatedItems: [PortfolioItemViewModel] = []
                var totalPortfolioValue: Double = 0
                var totalPortfolioProfitLoss: Double = 0
                var totalCost: Double = 0
                
                for dbItem in dbPortfolioItems {
                    if let coin = coins.first(where: { $0.id == dbItem.cryptoId }) {
                        // Calculate values
                        let currentValue = dbItem.quantity * coin.currentPrice
                        let costBasis = dbItem.quantity * dbItem.averageBuyPrice
                        let profitLoss = currentValue - costBasis
                        let profitLossPercentage = costBasis > 0 ? (profitLoss / costBasis) * 100 : 0
                        
                        // Create view model
                        let itemViewModel = PortfolioItemViewModel(
                            id: dbItem.id,
                            cryptoId: dbItem.cryptoId,
                            name: dbItem.cryptoName,
                            symbol: dbItem.cryptoSymbol,
                            quantity: dbItem.quantity,
                            averageBuyPrice: dbItem.averageBuyPrice,
                            currentPrice: coin.currentPrice,
                            currentValue: currentValue,
                            profitLoss: profitLoss,
                            profitLossPercentage: profitLossPercentage,
                            imageUrl: coin.image
                        )
                        
                        updatedItems.append(itemViewModel)
                        
                        // Update totals
                        totalPortfolioValue += currentValue
                        totalPortfolioProfitLoss += profitLoss
                        totalCost += costBasis
                    }
                }
                
                // Sort by value (descending)
                updatedItems.sort { $0.currentValue > $1.currentValue }
                
                // Update published properties
                self?.portfolioItems = updatedItems
                self?.totalValue = totalPortfolioValue
                self?.totalProfitLoss = totalPortfolioProfitLoss
                self?.profitLossPercentage = totalCost > 0 ? (totalPortfolioProfitLoss / totalCost) * 100 : 0
            })
            .store(in: &cancellables)
    }
    
    
    // Refreshes portfolio data
    func refreshData() {
        loadPortfolio()
    }
    
    
    //Resets user account to initial state
    //
    func resetAccount() -> Bool {
        // Get current balance
        guard var balance = databaseManager.getUserBalance() else {
            errorMessage = "Failed to get user balance"
            return false
        }
        
        // Reset balance
        balance.reset()
        
        if !databaseManager.updateUserBalance(balance) {
            errorMessage = "Failed to reset balance"
            return false
        }
        
        // Remove all portfolio items by setting quantities to zero
        for var item in databaseManager.getPortfolio() {
            item.quantity = 0
            databaseManager.savePortfolioItem(item)
        }
        
        // Refresh data
        loadPortfolio()
        successMessage = "Account has been reset to initial balance of $\(balance.initialBalance)"
        
        return true
    }
}


//View model for PortfolioItemView
//Contains all the data needed to display a portfolio item
struct PortfolioItemViewModel: Identifiable {
    let id: String
    let cryptoId: String
    let name: String
    let symbol: String
    let quantity: Double
    let averageBuyPrice: Double
    let currentPrice: Double
    let currentValue: Double
    let profitLoss: Double
    let profitLossPercentage: Double
    let imageUrl: String
    
    var formattedQuantity: String {
        return String(format: "%.6f", quantity)
    }
    
    var formattedAverageBuyPrice: String {
        return String(format: "$%.2f", averageBuyPrice)
    }
    
    var formattedCurrentPrice: String {
        return String(format: "$%.2f", currentPrice)
    }
    
    var formattedCurrentValue: String {
        return String(format: "$%.2f", currentValue)
    }
    
    var formattedProfitLoss: String {
        return String(format: "$%.2f", profitLoss)
    }
    
    var formattedProfitLossPercentage: String {
        return String(format: "%.2f%%", profitLossPercentage)
    }
    
    var isProfitable: Bool {
        return profitLoss > 0
    }
}
