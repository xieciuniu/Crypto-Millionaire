//
//  Cryptocurrency.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import SwiftUI

struct Cryptocurrency: Identifiable, Codable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double?
    let marketCapRank: Int?
    let priceChangePercentage24h: Double?
    let lastUpdated: String
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case lastUpdated = "last_updated"
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: currentPrice)) ?? "$0.00"
    }
    
    var priceChangeColor: Color {
        guard let priceChange = priceChangePercentage24h else {
            return .gray
        }
        return priceChange >= 0 ? .green : .red
    }
    
    var formattedPriceChange: String {
        guard let priceChange = priceChangePercentage24h else {
            return "0.00%"
        }
        return String(format: "%.2f%%", priceChange)
    }
}
