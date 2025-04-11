//
//  UIComponents.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 10/04/2025.
//

import SwiftUI

// Szklana karta
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(CryptoTheme.cardGradient)
                .background(.ultraThinMaterial)
                .blur(radius: 0.5)
            
            content
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
}

// Przycisk akcji
struct CryptoButton: View {
    let title: String
    let action: () -> Void
    let color: Color
    let isLoading: Bool
    
    init(title: String, color: Color = CryptoTheme.accent, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color)
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                }
            }
            .frame(height: 50)
        }
        .disabled(isLoading)
    }
}

// Mały numer procentowy zmiany
struct TrendLabel: View {
    let value: Double
    let showIcon: Bool
    
    init(value: Double, showIcon: Bool = true) {
        self.value = value
        self.showIcon = showIcon
    }
    
    var isPositive: Bool {
        return value >= 0
    }
    
    var body: some View {
        HStack(spacing: 2) {
            if showIcon {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption2)
            }
            
            Text(String(format: "%.2f%%", abs(value)))
                .fontWeight(.medium)
        }
        .foregroundColor(CryptoTheme.trendColor(isPositive))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(CryptoTheme.trendColor(isPositive).opacity(0.15))
        .cornerRadius(8)
    }
}

// Widżet z wartością salda
struct BalanceWidget: View {
    let title: String
    let amount: Double
    let trend: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 6) {
                Text("$\(String(format: "%.2f", amount))")
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let trend = trend {
                    TrendLabel(value: trend)
                        .padding(.bottom, 2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}
