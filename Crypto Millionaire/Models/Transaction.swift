//
//  Transaction.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let cryptoId: String
    let cryptoSymbol: String
    let cryptoName: String
    let type: TransactionType
    let amount: Double
    let price: Double
    let quantity: Double
    let fee: Double
    let timestamp: Date
    
    enum TransactionType: String, Codable {
        case buy
        case sell
    }
    
    var totalValue: Double {
        return quantity * price
    }
    
    var feeAmount: Double {
        return totalValue * fee
    }
    
    var netAmount: Double {
        switch type {
        case .buy:
            return -(totalValue + feeAmount)
        case .sell:
            return totalValue - feeAmount
        }
    }
}

extension Transaction {
    init(cryptoId: String, cryptoSymbol: String, cryptoName: String, type: TransactionType, price: Double, quantity: Double, fee: Double = 0.001) {
        self.id = UUID().uuidString
        self.cryptoId = cryptoId
        self.cryptoSymbol = cryptoSymbol
        self.cryptoName = cryptoName
        self.type = type
        self.amount = price * quantity
        self.price = price
        self.quantity = quantity
        self.fee = fee
        self.timestamp = Date()
    }
}
