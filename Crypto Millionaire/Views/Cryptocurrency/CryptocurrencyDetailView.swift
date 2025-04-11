//
//  CryptocurrencyDetailView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI
import Charts

struct CryptocurrencyDetailsView: View {
    let cryptocurrency: Cryptocurrency
    @StateObject private var viewModel = CryptocurrencyDetailsViewModel()
    @State private var showingTradeView = false
    @State private var tradeType: TradeType = .buy
    @Environment(\.dismiss) private var dismiss
    
    enum TradeType {
        case buy, sell
    }
    
    var body: some View {
        ZStack {
            // Tło
            Color(.systemBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    chartView
                    
                    statsView
                    
                    tradeButtonsView
                    
                    if viewModel.portfolioQuantity > 0 {
                        portfolioInfoView
                    }
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingTradeView) {
            TradeView(
                cryptocurrency: cryptocurrency,
                tradeType: tradeType
            )
        }
        .onAppear {
            viewModel.loadCryptocurrencyDetails(id: cryptocurrency.id)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button {
                    viewModel.refreshData()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            
            HStack(alignment: .center, spacing: 16) {
                // Logo
                AsyncImage(url: URL(string: cryptocurrency.image)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                } placeholder: {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(cryptocurrency.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(cryptocurrency.symbol.uppercased())
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(cryptocurrency.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let priceChange = cryptocurrency.priceChangePercentage24h {
                        TrendLabel(value: priceChange)
                    }
                }
            }
        }
    }
    
    private var chartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Price Chart")
                .font(.headline)
            
            if viewModel.isLoading && viewModel.chartPoints.isEmpty {
                ProgressView()
                    .frame(height: 250)
            } else if !viewModel.chartPoints.isEmpty {
                Chart {
                    ForEach(viewModel.chartPoints) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(Color.blue)
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 250)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYScale(domain: minMaxPriceRange)
                .padding(.vertical, 8)
            } else {
                Text("Chart data unavailable")
                    .foregroundColor(.secondary)
                    .frame(height: 250)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    // Zakres cen dla wykresu
    private var minMaxPriceRange: ClosedRange<Double> {
        let prices = viewModel.chartPoints.map { $0.price }
        if let min = prices.min(), let max = prices.max() {
            // Dodaj trochę paddingu do zakresu
            let padding = (max - min) * 0.1
            return (min - padding)...(max + padding)
        }
        return 0...100
    }
    
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Market Stats")
                .font(.headline)
            
            HStack {
                StatItem(
                    title: "Market Cap",
                    value: cryptocurrency.marketCap != nil ? formatCurrency(value: cryptocurrency.marketCap!) : "N/A"
                )
                
                Divider()
                
                StatItem(
                    title: "Volume",
                    value: cryptocurrency.marketCap != nil ? formatCurrency(value: cryptocurrency.marketCap! * 0.1) : "N/A"
                )
                
                Divider()
                
                StatItem(
                    title: "Rank",
                    value: cryptocurrency.marketCapRank != nil ? "#\(cryptocurrency.marketCapRank!)" : "N/A"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private struct StatItem: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var tradeButtonsView: some View {
        HStack(spacing: 16) {
            CryptoButton(title: "Buy", color: CryptoTheme.green) {
                tradeType = .buy
                showingTradeView = true
            }
            
            CryptoButton(title: "Sell", color: CryptoTheme.red) {
                tradeType = .sell
                showingTradeView = true
            }
        }
    }
    
    // Wallet information
    private var portfolioInfoView: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Position")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.6f", viewModel.portfolioQuantity))")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Value")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(String(format: "%.2f", viewModel.portfolioQuantity * cryptocurrency.currentPrice))")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
            }
        }
    }
    
    // Helper
    private func formatCurrency(value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        
        if value >= 1_000_000_000 {
            return "$\(String(format: "%.2f", value / 1_000_000_000))B"
        } else if value >= 1_000_000 {
            return "$\(String(format: "%.2f", value / 1_000_000))M"
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "$0"
        }
    }
}

struct CryptocurrencyDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCrypto = Cryptocurrency(
            id: "bitcoin",
            symbol: "btc",
            name: "Bitcoin",
            image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png",
            currentPrice: 55000.0,
            marketCap: 1000000000000,
            marketCapRank: 1,
            priceChangePercentage24h: 5.25,
            lastUpdated: "2025-04-09T12:00:00Z"
        )
        
        CryptocurrencyDetailsView(cryptocurrency: sampleCrypto)
    }
}

