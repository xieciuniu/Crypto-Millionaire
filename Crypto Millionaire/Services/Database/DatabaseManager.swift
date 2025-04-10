//
//  DatabaseManager.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import SQLite

// Create type aliases for SQLite types to avoid namespace conflicts
// This avoids the circular reference problem
typealias SQLiteTable = SQLite.Table
typealias SQLiteConnection = SQLite.Connection
typealias SQLiteExpression<T> = SQLite.Expression<T>

/**
 * DatabaseManager - Singleton class for handling SQLite database operations
 * Manages transactions, portfolio, user balance, and best trades for the Crypto Millionaire app
 */
class DatabaseManager {
    // Shared singleton instance
    static let shared = DatabaseManager()
    
    // Database connection
    private var db: SQLiteConnection?
    
    // Table definitions
    private let transactionsTable = SQLiteTable("transactions")
    private let portfolioTable = SQLiteTable("portfolio")
    private let userBalanceTable = SQLiteTable("user_balance")
    private let bestTradesTable = SQLiteTable("best_trades")
    
    // =============================================
    // Column definitions for Transaction table
    // =============================================
    private let transactionId = SQLiteExpression<String>("id")
    private let transactionCryptoId = SQLiteExpression<String>("crypto_id")
    private let transactionCryptoSymbol = SQLiteExpression<String>("crypto_symbol")
    private let transactionCryptoName = SQLiteExpression<String>("crypto_name")
    private let transactionType = SQLiteExpression<String>("type")
    private let transactionAmount = SQLiteExpression<Double>("amount")
    private let transactionPrice = SQLiteExpression<Double>("price")
    private let transactionQuantity = SQLiteExpression<Double>("quantity")
    private let transactionFee = SQLiteExpression<Double>("fee")
    private let transactionTimestamp = SQLiteExpression<Date>("timestamp")
    
    // =============================================
    // Column definitions for Portfolio table
    // =============================================
    private let portfolioId = SQLiteExpression<String>("id")
    private let portfolioCryptoId = SQLiteExpression<String>("crypto_id")
    private let portfolioCryptoSymbol = SQLiteExpression<String>("crypto_symbol")
    private let portfolioCryptoName = SQLiteExpression<String>("crypto_name")
    private let portfolioQuantity = SQLiteExpression<Double>("quantity")
    private let portfolioAverageBuyPrice = SQLiteExpression<Double>("average_buy_price")
    
    // =============================================
    // Column definitions for UserBalance table
    // =============================================
    private let userBalanceValue = SQLiteExpression<Double>("balance")
    private let userInitialBalance = SQLiteExpression<Double>("initial_balance")
    private let userBalanceTimestamp = SQLiteExpression<Date>("timestamp")
    
    // =============================================
    // Column definitions for BestTrade table
    // =============================================
    private let bestTradeId = SQLiteExpression<String>("id")
    private let bestTradeCryptoId = SQLiteExpression<String>("crypto_id")
    private let bestTradeCryptoSymbol = SQLiteExpression<String>("crypto_symbol")
    private let bestTradeCryptoName = SQLiteExpression<String>("crypto_name")
    private let bestTradeBuyPrice = SQLiteExpression<Double>("buy_price")
    private let bestTradeSellPrice = SQLiteExpression<Double>("sell_price")
    private let bestTradeQuantity = SQLiteExpression<Double>("quantity")
    private let bestTradeProfit = SQLiteExpression<Double>("profit")
    private let bestTradeProfitPercentage = SQLiteExpression<Double>("profit_percentage")
    private let bestTradeBuyTimestamp = SQLiteExpression<Date>("buy_timestamp")
    private let bestTradeSellTimestamp = SQLiteExpression<Date>("sell_timestamp")
    
    /**
     * Private initializer to enforce singleton pattern
     * Sets up the database connection and creates tables if they don't exist
     */
    private init() {
        do {
            // Get the path to the documents directory for database storage
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            // Initialize the database connection
            db = try SQLiteConnection("\(path)/crypto_millionaire.sqlite3")
            // Create tables if they don't exist
            createTables()
        } catch {
            print("Database initialization failed: \(error)")
        }
    }
    
    /**
     * Creates the necessary database tables if they don't exist
     * Also initializes user balance with default values if it doesn't exist
     */
    private func createTables() {
        do {
            // Create transactions table
            try db?.run(transactionsTable.create(ifNotExists: true) { table in
                table.column(transactionId, primaryKey: true)
                table.column(transactionCryptoId)
                table.column(transactionCryptoSymbol)
                table.column(transactionCryptoName)
                table.column(transactionType)
                table.column(transactionAmount)
                table.column(transactionPrice)
                table.column(transactionQuantity)
                table.column(transactionFee)
                table.column(transactionTimestamp)
            })
            
            // Create portfolio table
            try db?.run(portfolioTable.create(ifNotExists: true) { table in
                table.column(portfolioId, primaryKey: true)
                table.column(portfolioCryptoId, unique: true)
                table.column(portfolioCryptoSymbol)
                table.column(portfolioCryptoName)
                table.column(portfolioQuantity)
                table.column(portfolioAverageBuyPrice)
            })
            
            // Create user_balance table
            try db?.run(userBalanceTable.create(ifNotExists: true) { table in
                table.column(userBalanceValue)
                table.column(userInitialBalance)
                table.column(userBalanceTimestamp)
            })
            
            // Create best_trades table
            try db?.run(bestTradesTable.create(ifNotExists: true) { table in
                table.column(bestTradeId, primaryKey: true)
                table.column(bestTradeCryptoId)
                table.column(bestTradeCryptoSymbol)
                table.column(bestTradeCryptoName)
                table.column(bestTradeBuyPrice)
                table.column(bestTradeSellPrice)
                table.column(bestTradeQuantity)
                table.column(bestTradeProfit)
                table.column(bestTradeProfitPercentage)
                table.column(bestTradeBuyTimestamp)
                table.column(bestTradeSellTimestamp)
            })
            
            // Initialize user balance if it doesn't exist
            if try db?.scalar(userBalanceTable.count) == 0 {
                let defaultBalance = UserBalance.defaultBalance()
                
                try db?.run(userBalanceTable.insert(
                    userBalanceValue <- defaultBalance.balance,
                    userInitialBalance <- defaultBalance.initialBalance,
                    userBalanceTimestamp <- defaultBalance.timestamp
                ))
            }
            
        } catch {
            print("Table creation failed: \(error)")
        }
    }
    
    // MARK: - Transaction Repository Methods
    
    /**
     * Saves a transaction to the database
     * @param transaction The transaction to save
     * @return Bool indicating success or failure
     */
    func saveTransaction(_ transaction: Transaction) -> Bool {
        do {
            try db?.run(transactionsTable.insert(
                transactionId <- transaction.id,
                transactionCryptoId <- transaction.cryptoId,
                transactionCryptoSymbol <- transaction.cryptoSymbol,
                transactionCryptoName <- transaction.cryptoName,
                transactionType <- transaction.type.rawValue,
                transactionAmount <- transaction.amount,
                transactionPrice <- transaction.price,
                transactionQuantity <- transaction.quantity,
                transactionFee <- transaction.fee,
                transactionTimestamp <- transaction.timestamp
            ))
            return true
        } catch {
            print("Failed to save transaction: \(error)")
            return false
        }
    }
    
    /**
     * Retrieves all transactions from the database, ordered by timestamp descending
     * @return Array of Transaction objects
     */
    func getTransactions() -> [Transaction] {
        var transactions: [Transaction] = []
        
        do {
            let query = transactionsTable.order(transactionTimestamp.desc)
            
            if let rows = try db?.prepare(query) {
                for row in rows {
                    let typeString: String = try row.get(transactionType)
                    let type = Transaction.TransactionType(rawValue: typeString) ?? .buy
                    
                    let transaction = Transaction(
                        id: try row.get(transactionId),
                        cryptoId: try row.get(transactionCryptoId),
                        cryptoSymbol: try row.get(transactionCryptoSymbol),
                        cryptoName: try row.get(transactionCryptoName),
                        type: type,
                        amount: try row.get(transactionAmount),
                        price: try row.get(transactionPrice),
                        quantity: try row.get(transactionQuantity),
                        fee: try row.get(transactionFee),
                        timestamp: try row.get(transactionTimestamp)
                    )
                    
                    transactions.append(transaction)
                }
            }
        } catch {
            print("Failed to get transactions: \(error)")
        }
        
        return transactions
    }
    
    // MARK: - Portfolio Repository Methods
    
    /**
     * Saves or updates a portfolio item in the database
     * If an item with the same cryptoId exists, it will be updated; otherwise, a new item will be created
     * @param item The portfolio item to save
     * @return Bool indicating success or failure
     */
    func savePortfolioItem(_ item: Portfolio) -> Bool {
        do {
            // Check if there's an existing item for this cryptocurrency
            let existingItem = portfolioTable.filter(portfolioCryptoId == item.cryptoId)
            
            if try db?.scalar(existingItem.count) ?? 0 > 0 {
                // Update existing item
                try db?.run(existingItem.update(
                    portfolioQuantity <- item.quantity,
                    portfolioAverageBuyPrice <- item.averageBuyPrice
                ))
            } else {
                // Add new item
                try db?.run(portfolioTable.insert(
                    portfolioId <- item.id,
                    portfolioCryptoId <- item.cryptoId,
                    portfolioCryptoSymbol <- item.cryptoSymbol,
                    portfolioCryptoName <- item.cryptoName,
                    portfolioQuantity <- item.quantity,
                    portfolioAverageBuyPrice <- item.averageBuyPrice
                ))
            }
            return true
        } catch {
            print("Failed to save portfolio item: \(error)")
            return false
        }
    }
    
    /**
     * Retrieves all portfolio items with quantity > 0 from the database
     * @return Array of Portfolio objects
     */
    func getPortfolio() -> [Portfolio] {
        var portfolio: [Portfolio] = []
        
        do {
            let query = portfolioTable.filter(portfolioQuantity > 0)
            
            if let rows = try db?.prepare(query) {
                for row in rows {
                    let item = Portfolio(
                        id: try row.get(portfolioId),
                        cryptoId: try row.get(portfolioCryptoId),
                        cryptoSymbol: try row.get(portfolioCryptoSymbol),
                        cryptoName: try row.get(portfolioCryptoName),
                        quantity: try row.get(portfolioQuantity),
                        averageBuyPrice: try row.get(portfolioAverageBuyPrice)
                    )
                    
                    portfolio.append(item)
                }
            }
        } catch {
            print("Failed to get portfolio: \(error)")
        }
        
        return portfolio
    }
    
    // MARK: - UserBalance Repository Methods
    
    /**
     * Retrieves the current user balance from the database
     * @return UserBalance object or nil if not found
     */
    func getUserBalance() -> UserBalance? {
        do {
            if let row = try db?.pluck(userBalanceTable) {
                return UserBalance(
                    balance: try row.get(userBalanceValue),
                    initialBalance: try row.get(userInitialBalance),
                    timestamp: try row.get(userBalanceTimestamp)
                )
            }
        } catch {
            print("Failed to get user balance: \(error)")
        }
        
        return nil
    }
    
    /**
     * Updates the user balance in the database
     * @param balance The updated user balance
     * @return Bool indicating success or failure
     */
    func updateUserBalance(_ balance: UserBalance) -> Bool {
        do {
            try db?.run(userBalanceTable.update(
                userBalanceValue <- balance.balance,
                userInitialBalance <- balance.initialBalance,
                userBalanceTimestamp <- balance.timestamp
            ))
            return true
        } catch {
            print("Failed to update user balance: \(error)")
            return false
        }
    }
    
    // MARK: - BestTrade Repository Methods
    
    /**
     * Saves a best trade record to the database
     * @param trade The best trade to save
     * @return Bool indicating success or failure
     */
    func saveBestTrade(_ trade: BestTrade) -> Bool {
        do {
            try db?.run(bestTradesTable.insert(
                bestTradeId <- trade.id,
                bestTradeCryptoId <- trade.cryptoId,
                bestTradeCryptoSymbol <- trade.cryptoSymbol,
                bestTradeCryptoName <- trade.cryptoName,
                bestTradeBuyPrice <- trade.buyPrice,
                bestTradeSellPrice <- trade.sellPrice,
                bestTradeQuantity <- trade.quantity,
                bestTradeProfit <- trade.profit,
                bestTradeProfitPercentage <- trade.profitPercentage,
                bestTradeBuyTimestamp <- trade.buyTimestamp,
                bestTradeSellTimestamp <- trade.sellTimestamp
            ))
            return true
        } catch {
            print("Failed to save best trade: \(error)")
            return false
        }
    }
    
    /**
     * Retrieves the best trades from the database, ordered by profit descending
     * @param limit Maximum number of trades to return (default: 10)
     * @return Array of BestTrade objects
     */
    func getBestTrades(limit: Int = 10) -> [BestTrade] {
        var trades: [BestTrade] = []
        
        do {
            let query = bestTradesTable.order(bestTradeProfit.desc).limit(limit)
            
            if let rows = try db?.prepare(query) {
                for row in rows {
                    let trade = BestTrade(
                        id: try row.get(bestTradeId),
                        cryptoId: try row.get(bestTradeCryptoId),
                        cryptoSymbol: try row.get(bestTradeCryptoSymbol),
                        cryptoName: try row.get(bestTradeCryptoName),
                        buyPrice: try row.get(bestTradeBuyPrice),
                        sellPrice: try row.get(bestTradeSellPrice),
                        quantity: try row.get(bestTradeQuantity),
                        profit: try row.get(bestTradeProfit),
                        profitPercentage: try row.get(bestTradeProfitPercentage),
                        buyTimestamp: try row.get(bestTradeBuyTimestamp),
                        sellTimestamp: try row.get(bestTradeSellTimestamp)
                    )
                    
                    trades.append(trade)
                }
            }
        } catch {
            print("Failed to get best trades: \(error)")
        }
        
        return trades
    }
    
    /**
     * Deletes all data from the database and resets to initial state
     * Useful for development and testing purposes
     * @return Bool indicating success or failure
     */
    func resetAllData() -> Bool {
        do {
            // Delete all data from tables
            try db?.run(transactionsTable.delete())
            try db?.run(portfolioTable.delete())
            try db?.run(bestTradesTable.delete())
            
            // Reset user balance to default
            try db?.run(userBalanceTable.delete())
            let defaultBalance = UserBalance.defaultBalance()
            
            try db?.run(userBalanceTable.insert(
                userBalanceValue <- defaultBalance.balance,
                userInitialBalance <- defaultBalance.initialBalance,
                userBalanceTimestamp <- defaultBalance.timestamp
            ))
            
            return true
        } catch {
            print("Failed to reset database: \(error)")
            return false
        }
    }
}
