//
//  CryptoRowView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI
import Kingfisher

struct CryptoRowView: View {
    let cryptocurrency: Cryptocurrency
    let showRank: Bool
    
    init(cryptocurrency: Cryptocurrency, showRank: Bool = true) {
        self.cryptocurrency = cryptocurrency
        self.showRank = showRank
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo
            KFImage(URL(string: cryptocurrency.image))
                .placeholder {
                    Image(systemName: "bitcoinsign.circle")
                        .foregroundColor(CryptoTheme.accent)
                        .font(.title)
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .cornerRadius(20)
            
            // Name and symbol
            VStack(alignment: .leading, spacing: 4) {
                Text(cryptocurrency.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(cryptocurrency.symbol.uppercased())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price and change
            VStack(alignment: .trailing, spacing: 4) {
                Text(cryptocurrency.formattedPrice)
                    .font(.headline)
                    .fontWeight(.bold)
                
                if let priceChange = cryptocurrency.priceChangePercentage24h {
                    TrendLabel(value: priceChange)
                }
            }
            
            if showRank, let rank = cryptocurrency.marketCapRank {
                Text("#\(rank)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 40)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground).opacity(0.5))
        .cornerRadius(16)
    }
}

