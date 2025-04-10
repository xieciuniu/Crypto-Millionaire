//
//  CryptocurrencyListViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import Combine

class CryptocurrencyListViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var filteredCryptocurrencies: [Cryptocurrency] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    private var coinGeckoService: CoinGeckoService
    
    init(apiKey: String = ApiConfig.coinGeckoApiKey) {
        self.coinGeckoService = CoinGeckoService(apiKey: apiKey)
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.filterCryptocurrencies(text)
            }
            .store(in: &cancellables)
        
        // Initial data load
        loadCryptocurrencies()
    }
    
    // Loads cryptocurrency data from API
    func loadCryptocurrencies() {
        isLoading = true
        errorMessage = nil
        
        coinGeckoService.getCoins()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to load cryptocurrencies: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] coins in
                self?.cryptocurrencies = coins
                self?.filterCryptocurrencies(self?.searchText ?? "")
            })
            .store(in: &cancellables)
    }
    
    // Filters cryptocurriences based on search text
    private func filterCryptocurrencies(_ searchText: String) {
        if searchText.isEmpty {
            filteredCryptocurrencies = cryptocurrencies
        } else {
            filteredCryptocurrencies = cryptocurrencies.filter { coin in
                coin.name.lowercased().contains(searchText.lowercased()) ||
                coin.symbol.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    // manual refresh of curptocurrency data
    func refreshData() {
        loadCryptocurrencies()
    }
}
