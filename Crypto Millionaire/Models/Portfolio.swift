//
//  Portfolio.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation

struct Portfolio: Codable, Identifiable {
    let id: String
    let cryptoId: String
    let cryptoSymbol: String
    let cryptoName: String
    var quantity: Double
    var averageBuyPrice: Double
    
    var currentValue: Double = 0.0
    var profitLoss: Double = 0.0
    var profitLossPercentage: Double = 0.0
    
    enum CodingKeys: String, CodingKey {
        case id
        case cryptoId
        case cryptoSymbol
        case cryptoName
        case quantity
        case averageBuyPrice
    }
}


extension Portfolio {
    mutating func updateCurrentValue(withPrice price: Double) {
        currentValue = quantity * price
        profitLoss = currentValue - (averageBuyPrice * quantity)
        profitLossPercentage = (price - averageBuyPrice) / averageBuyPrice * 100
    }
    
    mutating func add(quantity: Double, atPrice price: Double) {
        let newTotalCost = (self.quantity * self.averageBuyPrice) + (quantity * price)
        let newTotalQuantity = self.quantity + quantity
        self.averageBuyPrice = newTotalCost / newTotalQuantity
        self.quantity = newTotalQuantity
    }
    
    mutating func subtract(quantity: Double) {
        self.quantity -= quantity
    }
}
