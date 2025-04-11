//
//  Color+Extentions.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct CryptoTheme {
    // Główne kolory
    static let accent = Color("AccentColor")
    static let background = Color("BackgroundColor")
    static let secondaryBackground = Color("SecondaryBackgroundColor")
    
    // Kolory kryptowalut
    static let bitcoin = Color(hex: "F7931A")
    static let ethereum = Color(hex: "627EEA")
    static let ripple = Color(hex: "0085C0")
    
    // Kolory funkcjonalne
    static let green = Color(hex: "4BC68B")
    static let red = Color(hex: "FF5B5B")
    static let yellow = Color(hex: "F7C035")
    
    // Gradienty
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.7)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        gradient: Gradient(colors: [Color.white.opacity(0.1), Color.white.opacity(0.05)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static func trendColor(_ isPositive: Bool) -> Color {
        return isPositive ? green : red
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
