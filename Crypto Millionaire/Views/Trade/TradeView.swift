//
//  TradeView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct TradeView: View {
    let cryptocurrency: Cryptocurrency
    let tradeType: CryptocurrencyDetailsView.TradeType
    @StateObject private var viewModel = TradeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Nagłówek
                    headerView
                    
                    // Formularz
                    if tradeType == .buy {
                        BuyFormView(viewModel: viewModel)
                    } else {
                        SellFormView(viewModel: viewModel)
                    }
                    
                    Spacer()
                    
                    // Przycisk akcji
                    actionButton
                }
                .padding()
                .alert(isPresented: Binding<Bool>(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )) {
                    Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? ""), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarHidden(true)
            .onChange(of: viewModel.successMessage) { newValue, oldValue in
                if newValue != nil {
                    // Auto-dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.setup(with: cryptocurrency)
        }
    }
    
    private var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text(tradeType == .buy ? "Buy \(cryptocurrency.symbol.uppercased())" : "Sell \(cryptocurrency.symbol.uppercased())")
                .font(.headline)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
        }
    }
    
    private var actionButton: some View {
        CryptoButton(
            title: tradeType == .buy ? "Buy \(cryptocurrency.symbol.uppercased())" : "Sell \(cryptocurrency.symbol.uppercased())",
            color: tradeType == .buy ? CryptoTheme.green : CryptoTheme.red,
            isLoading: viewModel.isLoading
        ) {
            if tradeType == .buy {
                viewModel.executeBuy()
            } else {
                viewModel.executeSell()
            }
        }
    }
}

struct BuyFormView: View {
    @ObservedObject var viewModel: TradeViewModel
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            cryptoInfoView
            
            formView
            
            summaryView
        }
    }
    
    private var cryptoInfoView: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: viewModel.cryptocurrency?.image ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                Image(systemName: "bitcoinsign.circle")
                    .font(.largeTitle)
                    .foregroundColor(CryptoTheme.accent)
            }
            .background(Color.white.opacity(0.2))
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.cryptocurrency?.name ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Current Price: \(viewModel.cryptocurrency?.formattedPrice ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var formView: some View {
        VStack(spacing: 16) {
            Text("How much do you want to buy?")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Available: $\(String(format: "%.2f", viewModel.userBalance?.balance ?? 0))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    TextField("0.0", value: $viewModel.quantity, format: .number)
                        .font(.title2)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .focused($isFieldFocused)
                    
                    Spacer()
                    
                    Text(viewModel.cryptocurrency?.symbol.uppercased() ?? "")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            Slider(value: $viewModel.quantity, in: 0...(viewModel.userBalance?.balance ?? 0) / (viewModel.currentPrice > 0 ? viewModel.currentPrice : 1))
                .accentColor(CryptoTheme.accent)
            
            HStack(spacing: 8) {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { fraction in
                    Button {
                        let maxAmount = (viewModel.userBalance?.balance ?? 0) / (viewModel.currentPrice > 0 ? viewModel.currentPrice : 1)
                        viewModel.quantity = maxAmount * fraction
                    } label: {
                        Text(fraction == 1.0 ? "Max" : "\(Int(fraction * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var summaryView: some View {
        VStack(spacing: 16) {
            Text("Order Summary")
                .font(.headline)
            
            Group {
                summaryRow(title: "Price", value: "$\(String(format: "%.2f", viewModel.currentPrice))")
                summaryRow(title: "Quantity", value: "\(String(format: "%.6f", viewModel.quantity))")
                summaryRow(title: "Total", value: "$\(String(format: "%.2f", viewModel.totalAmount))")
                summaryRow(title: "Fee (0.1%)", value: "$\(String(format: "%.2f", viewModel.fee))")
                
                Divider()
                
                summaryRow(title: "Total Payment", value: "$\(String(format: "%.2f", viewModel.netAmount))", highlight: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func summaryRow(title: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(highlight ? .headline : .subheadline)
                .foregroundColor(highlight ? .primary : .secondary)
            
            Spacer()
            
            Text(value)
                .font(highlight ? .headline : .subheadline)
                .fontWeight(highlight ? .bold : .regular)
        }
    }
}

struct SellFormView: View {
    @ObservedObject var viewModel: TradeViewModel
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            cryptoInfoView
            
            formView

            summaryView
        }
    }
    
    private var cryptoInfoView: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: viewModel.cryptocurrency?.image ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                Image(systemName: "bitcoinsign.circle")
                    .font(.largeTitle)
                    .foregroundColor(CryptoTheme.accent)
            }
            .background(Color.white.opacity(0.2))
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.cryptocurrency?.name ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Current Price: \(viewModel.cryptocurrency?.formattedPrice ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var formView: some View {
        VStack(spacing: 16) {
            Text("How much do you want to sell?")
                .font(.headline)
            
            VStack(spacing: 8) {
                HStack {
                    Text("Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Available: \(String(format: "%.6f", viewModel.portfolioQuantity))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    TextField("0.0", value: $viewModel.quantity, format: .number)
                        .font(.title2)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .focused($isFieldFocused)
                    
                    Spacer()
                    
                    Text(viewModel.cryptocurrency?.symbol.uppercased() ?? "")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            
            Slider(value: $viewModel.quantity, in: 0...viewModel.portfolioQuantity)
                .accentColor(CryptoTheme.red)
            
            HStack(spacing: 8) {
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { fraction in
                    Button {
                        viewModel.quantity = viewModel.portfolioQuantity * fraction
                    } label: {
                        Text(fraction == 1.0 ? "Max" : "\(Int(fraction * 100))%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var summaryView: some View {
        VStack(spacing: 16) {
            Text("Order Summary")
                .font(.headline)
            
            Group {
                summaryRow(title: "Price", value: "$\(String(format: "%.2f", viewModel.currentPrice))")
                summaryRow(title: "Quantity", value: "\(String(format: "%.6f", viewModel.quantity))")
                summaryRow(title: "Total", value: "$\(String(format: "%.2f", viewModel.totalAmount))")
                summaryRow(title: "Fee (0.1%)", value: "$\(String(format: "%.2f", viewModel.fee))")
                
                Divider()
                
                summaryRow(title: "Total Received", value: "$\(String(format: "%.2f", viewModel.totalAmount - viewModel.fee))", highlight: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func summaryRow(title: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(highlight ? .headline : .subheadline)
                .foregroundColor(highlight ? .primary : .secondary)
            
            Spacer()
            
            Text(value)
                .font(highlight ? .headline : .subheadline)
                .fontWeight(highlight ? .bold : .regular)
        }
    }
}


