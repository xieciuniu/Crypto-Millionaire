//
//  RankingView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.bestTrades.isEmpty {
                    emptyView
                } else {
                    // Lista najlepszych transakcji
                    scrollView
                }
            }
        }
        .onAppear {
            viewModel.loadBestTrades()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Best Trades")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Spacer()
            
            Button {
                viewModel.refreshData()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.primary)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading your best trades...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy")
                .font(.system(size: 70))
                .foregroundColor(CryptoTheme.yellow.opacity(0.7))
                .padding(.bottom, 16)
            
            Text("No Trades Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Complete some profitable trades to see them here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(viewModel.bestTrades.enumerated()), id: \.element.id) { index, trade in
                    BestTradeRow(trade: trade, rank: index + 1)
                }
            }
            .padding()
        }
    }
}

struct BestTradeRow: View {
    let trade: BestTrade
    let rank: Int
    
    var body: some View {
        GlassCard {
            HStack(alignment: .center, spacing: 16) {
                Text("#\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        rankBackgroundColor
                            .clipShape(Circle())
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(trade.cryptoName)
                        .font(.headline)
                    
                    Text("\(String(format: "%.6f", trade.quantity)) \(trade.cryptoSymbol.uppercased())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(trade.formattedProfit)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(CryptoTheme.green)
                    
                    Text(trade.formattedProfitPercentage)
                        .font(.subheadline)
                        .foregroundColor(CryptoTheme.green)
                }
            }
        }
    }
    
    private var rankBackgroundColor: Color {
        switch rank {
        case 1:
            return CryptoTheme.yellow
        case 2:
            return Color.gray.opacity(0.8)
        case 3:
            return Color(hex: "CD7F32")
        default:
            return CryptoTheme.accent.opacity(0.8)
        }
    }
}

#Preview {
    RankingView()
}
