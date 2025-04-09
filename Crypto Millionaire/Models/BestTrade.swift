//
//  BestTrade.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation

struct BestTrade: Identifiable, Codable {
    let id: String
    let cryptoId: String
    let cryptoSymbol: String
    let cryptoName: String
    let buyPrice: Double
    let sellPrice: Double
    let quantity: Double
    let profit: Double
    let profitPercentage: Double
    let buyTimestamp: Date
    let sellTimestamp: Date
    
    var formattedProfit: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: profit)) ?? "$0.00"
    }
    
    var formattedProfitPercentage: String {
        return String(format: "%.2f%%", profitPercentage)
    }
}
