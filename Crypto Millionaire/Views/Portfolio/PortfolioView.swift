//
//  PortfolioView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct PortfolioView: View {
    @StateObject private var viewModel = PortfolioViewModel()
    
    var body: some View {
        ZStack {
            CryptoTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerWithBalance
                
                if viewModel.portfolioItems.isEmpty {
                    emptyPortfolioView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.portfolioItems) { item in
                                PortfolioItemView(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadPortfolio()
        }
    }
    
    private var headerWithBalance: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Your Portfolio")
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
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Total Balance")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.2f", (viewModel.userBalance?.balance ?? 0) + viewModel.totalValue))")
                        .font(.system(size: 42, weight: .bold))
                    
                    if viewModel.profitLossPercentage != 0 {
                        TrendLabel(value: viewModel.profitLossPercentage)
                    }
                }
                .padding(.vertical, 8)
                
                HStack(spacing: 16) {
                    BalanceWidget(
                        title: "Cash Balance",
                        amount: viewModel.userBalance?.balance ?? 0,
                        trend: nil
                    )
                    
                    BalanceWidget(
                        title: "Portfolio Value",
                        amount: viewModel.totalValue,
                        trend: viewModel.profitLossPercentage
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(CryptoTheme.primaryGradient)
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
        }
        .padding(.top)
        .background(CryptoTheme.background)
    }
    
    private var emptyPortfolioView: some View {
        VStack(spacing: 24) {
            Image(systemName: "briefcase")
                .font(.system(size: 70))
                .foregroundColor(CryptoTheme.accent.opacity(0.7))
                .padding(.bottom, 16)
            
            Text("Your Portfolio is Empty")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start by purchasing some cryptocurrencies from the Market tab.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            NavigationLink(destination: CryptocurrencyListView()) {
                Text("Go to Market")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(CryptoTheme.accent)
                    .cornerRadius(16)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PortfolioItemView: View {
    let item: PortfolioItemViewModel
    
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                AsyncImage(url: URL(string: item.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                } placeholder: {
                    Image(systemName: "bitcoinsign.circle")
                        .font(.title)
                        .foregroundColor(CryptoTheme.accent)
                }
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                    
                    Text(item.symbol)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(item.formattedQuantity) tokens")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(item.formattedCurrentValue)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 4) {
                        Image(systemName: item.isProfitable ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        
                        Text(item.formattedProfitLoss)
                            .font(.subheadline)
                    }
                    .foregroundColor(item.isProfitable ? CryptoTheme.green : CryptoTheme.red)
                }
            }
        }
    }
}

#Preview {
    PortfolioView()
}
