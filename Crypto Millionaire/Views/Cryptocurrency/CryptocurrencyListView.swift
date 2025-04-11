//
//  CryptocurrencyListView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct CryptocurrencyListView: View {
    @StateObject private var viewModel = CryptocurrencyListViewModel()
    @State private var selectedCurrency: Cryptocurrency? = nil
    @State private var showingDetail = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemBackground)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                if viewModel.isLoading && viewModel.cryptocurrencies.isEmpty {
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.cryptocurrencies.isEmpty {
                    errorView(message: error)
                } else {
                    listView
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let crypto = selectedCurrency {
                CryptocurrencyDetailsView(cryptocurrency: crypto)
            }
        }
        .onAppear {
            if viewModel.cryptocurrencies.isEmpty {
                viewModel.loadCryptocurrencies()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Crypto Market")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search cryptocurrency", text: $viewModel.searchText)
                    .disableAutocorrection(true)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .padding(.top)
        .background(Color(.systemBackground))
    }
    
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredCryptocurrencies) { crypto in
                    CryptoRowView(cryptocurrency: crypto)
                        .onTapGesture {
                            selectedCurrency = crypto
                            showingDetail = true
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
        .refreshable {
            await withCheckedContinuation { continuation in
                viewModel.refreshData()
                continuation.resume()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading cryptocurrencies...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            CryptoButton(title: "Try Again", color: CryptoTheme.accent) {
                viewModel.loadCryptocurrencies()
            }
            .padding(.top, 8)
            .frame(width: 180)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

