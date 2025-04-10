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
    }
    
    
    
    
    
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
}
