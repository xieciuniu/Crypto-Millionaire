//
//  UserBalance.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation

struct UserBalance: Codable {
    var balance: Double
    var initialBalance: Double
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case balance, initialBalance, timestamp
    }
}

extension UserBalance {
    static func defaultBalance() -> UserBalance {
        return UserBalance(balance: 10000.0, initialBalance: 10000.0, timestamp: Date())
    }
    
    mutating func reset() {
        self.balance = self.initialBalance
        self.timestamp = Date()
    }
    mutating func update(amount: Double) {
        self.balance += amount
    }
}

