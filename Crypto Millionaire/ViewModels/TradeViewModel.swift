//
//  TradeViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import Combine


//View model for TradeView, BuyFormView and SellFormView
//Manages trading operations (buy/sell) for cryptocurrencies
class TradeViewModel: ObservableObject {
    @Published var cryptocurrency: Cryptocurrency? = nil
    @Published var currentPrice: Double = 0
    @Published var quantity: Double = 0
    @Published var totalAmount: Double = 0
    @Published var fee: Double = 0
    @Published var netAmount: Double = 0
    @Published var userBalance: UserBalance? = nil
    @Published var portfolioQuantity: Double = 0
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var isLoading: Bool = false
    
    private let databaseManager = DatabaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    
//    Initializes the view model with a cryptocurrency
    
    func setup(with cryptocurrency: Cryptocurrency) {
        self.cryptocurrency = cryptocurrency
        self.currentPrice = cryptocurrency.currentPrice
        
        // Load user balance
        userBalance = databaseManager.getUserBalance()
        
        // Load portfolio data for this cryptocurrency
        let portfolio = databaseManager.getPortfolio()
        if let portfolioItem = portfolio.first(where: { $0.cryptoId == cryptocurrency.id }) {
            portfolioQuantity = portfolioItem.quantity
        } else {
            portfolioQuantity = 0
        }
        
        // Setup quantity publisher to calculate trade amounts
        $quantity
            .sink { [weak self] quantity in
                self?.calculateTradeAmounts(quantity: quantity)
            }
            .store(in: &cancellables)
    }
    
    
//    Calculates trade amounts based on quantity
    private func calculateTradeAmounts(quantity: Double) {
        guard let price = cryptocurrency?.currentPrice else { return }
        
        totalAmount = price * quantity
        fee = totalAmount * 0.001 // 0.1% fee
        
        // Net amount depends on buy/sell operation
        // For preview purposes, we'll set it to the total + fee (as in buy operation)
        netAmount = totalAmount + fee
    }
    

    // Executes buy operation
    func executeBuy() {
        guard let crypto = cryptocurrency,
              let balance = userBalance,
              quantity > 0 else {
            errorMessage = "Invalid trade parameters"
            return
        }
        
        let totalCost = currentPrice * quantity
        let feeAmount = totalCost * 0.001 // 0.1% fee
        let totalAmount = totalCost + feeAmount
        
        // Check if user has enough funds
        if balance.balance < totalAmount {
            errorMessage = "Insufficient funds"
            return
        }
        
        isLoading = true
        
        // Create transaction
        let transaction = Transaction(
            cryptoId: crypto.id,
            cryptoSymbol: crypto.symbol,
            cryptoName: crypto.name,
            type: .buy,
            price: currentPrice,
            quantity: quantity
        )
        
        // Save transaction
        if !databaseManager.saveTransaction(transaction) {
            isLoading = false
            errorMessage = "Failed to save transaction"
            return
        }
        
        // Update user balance
        var updatedBalance = balance
        updatedBalance.update(amount: -totalAmount)
        
        if !databaseManager.updateUserBalance(updatedBalance) {
            isLoading = false
            errorMessage = "Failed to update balance"
            return
        }
        
        // Update portfolio
        let portfolio = databaseManager.getPortfolio()
        let existingItem = portfolio.first { $0.cryptoId == crypto.id }
        
        if var item = existingItem {
            item.add(quantity: quantity, atPrice: currentPrice)
            if !databaseManager.savePortfolioItem(item) {
                isLoading = false
                errorMessage = "Failed to update portfolio"
                return
            }
        } else {
            let newItem = Portfolio(
                id: UUID().uuidString,
                cryptoId: crypto.id,
                cryptoSymbol: crypto.symbol,
                cryptoName: crypto.name,
                quantity: quantity,
                averageBuyPrice: currentPrice
            )
            
            if !databaseManager.savePortfolioItem(newItem) {
                isLoading = false
                errorMessage = "Failed to update portfolio"
                return
            }
        }
        
        isLoading = false
        successMessage = "Successfully purchased \(quantity) \(crypto.symbol.uppercased())"
        
        // Refresh data
        userBalance = databaseManager.getUserBalance()
        let updatedPortfolio = databaseManager.getPortfolio()
        if let portfolioItem = updatedPortfolio.first(where: { $0.cryptoId == crypto.id }) {
            portfolioQuantity = portfolioItem.quantity
        }
        
        // Reset quantity
        quantity = 0
    }
    
    
//    Executes sell operation
    func executeSell() {
        guard let crypto = cryptocurrency,
              let balance = userBalance,
              quantity > 0 else {
            errorMessage = "Invalid trade parameters"
            return
        }
        
        // Check if user has enough cryptocurrency
        if portfolioQuantity < quantity {
            errorMessage = "Insufficient cryptocurrency amount"
            return
        }
        
        isLoading = true
        
        let totalValue = currentPrice * quantity
        let feeAmount = totalValue * 0.001 // 0.1% fee
        let netAmount = totalValue - feeAmount
        
        // Get portfolio item
        let portfolio = databaseManager.getPortfolio()
        guard var portfolioItem = portfolio.first(where: { $0.cryptoId == crypto.id }) else {
            isLoading = false
            errorMessage = "Portfolio item not found"
            return
        }
        
        // Create transaction
        let transaction = Transaction(
            cryptoId: crypto.id,
            cryptoSymbol: crypto.symbol,
            cryptoName: crypto.name,
            type: .sell,
            price: currentPrice,
            quantity: quantity
        )
        
        // Save transaction
        if !databaseManager.saveTransaction(transaction) {
            isLoading = false
            errorMessage = "Failed to save transaction"
            return
        }
        
        // Update user balance
        var updatedBalance = balance
        updatedBalance.update(amount: netAmount)
        
        if !databaseManager.updateUserBalance(updatedBalance) {
            isLoading = false
            errorMessage = "Failed to update balance"
            return
        }
        
        // Update portfolio
        portfolioItem.subtract(quantity: quantity)
        
        if !databaseManager.savePortfolioItem(portfolioItem) {
            isLoading = false
            errorMessage = "Failed to update portfolio"
            return
        }
        
        // Check if this was a profitable trade
        let profit = (currentPrice - portfolioItem.averageBuyPrice) * quantity
        let profitPercentage = (currentPrice - portfolioItem.averageBuyPrice) / portfolioItem.averageBuyPrice * 100
        
        if profit > 0 {
            let bestTrade = BestTrade(
                id: UUID().uuidString,
                cryptoId: crypto.id,
                cryptoSymbol: crypto.symbol,
                cryptoName: crypto.name,
                buyPrice: portfolioItem.averageBuyPrice,
                sellPrice: currentPrice,
                quantity: quantity,
                profit: profit,
                profitPercentage: profitPercentage,
                buyTimestamp: Date().addingTimeInterval(-86400), // Approximate buy date (day before)
                sellTimestamp: Date()
            )
            
            databaseManager.saveBestTrade(bestTrade)
        }
        
        isLoading = false
        successMessage = "Successfully sold \(quantity) \(crypto.symbol.uppercased())"
        
        // Refresh data
        userBalance = databaseManager.getUserBalance()
        let updatedPortfolio = databaseManager.getPortfolio()
        if let updatedItem = updatedPortfolio.first(where: { $0.cryptoId == crypto.id }) {
            portfolioQuantity = updatedItem.quantity
        } else {
            portfolioQuantity = 0
        }
        
        // Reset quantity
        quantity = 0
    }
}
