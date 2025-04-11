//
//  CryptocurrencyDetailViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import Combine
import Charts
import SwiftUI


 // View model for CryptocurrencyDetails view
 // Manages details data for a single cryptocurrency and trading operations
 
class CryptocurrencyDetailsViewModel: ObservableObject {
    @Published var cryptocurrency: CryptocurrencyDetail? = nil
    @Published var marketChartData: MarketChartData? = nil
    @Published var chartPoints: [PricePoint] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var tradeSuccess: Bool? = nil
    @Published var userBalance: UserBalance? = nil
    @Published var portfolioQuantity: Double = 0
    
    struct PricePoint: Identifiable {
        let id = UUID()
        let date: Date
        let price: Double
        let formattedDate: String
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let coinGeckoService: CoinGeckoService
    private let databaseManager = DatabaseManager.shared
    
    init(apiKey: String = ApiConfig.coinGeckoApiKey) {
        self.coinGeckoService = CoinGeckoService(apiKey: apiKey)
    }
    
    
   //  Loads details for a specific cryptocurrency
    
    func loadCryptocurrencyDetails(id: String) {
        isLoading = true
        errorMessage = nil
        
        // Load user balance and portfolio info
        userBalance = databaseManager.getUserBalance()
        loadPortfolioInfo(cryptoId: id)
        
        // Load cryptocurrency details from API
        coinGeckoService.getCoinDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to load cryptocurrency details: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] coinDetail in
                self?.cryptocurrency = coinDetail
                self?.loadMarketChart(id: id)
            })
            .store(in: &cancellables)
    }
    
     // Loads portfolio data for this cryptocurrency
    private func loadPortfolioInfo(cryptoId: String) {
        let portfolio = databaseManager.getPortfolio()
        if let portfolioItem = portfolio.first(where: { $0.cryptoId == cryptoId }) {
            portfolioQuantity = portfolioItem.quantity
        } else {
            portfolioQuantity = 0
        }
    }

    private func loadMarketChart(id: String) {
        coinGeckoService.getCoinMarketChart(id: id, days: 7)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = "Failed to load market chart: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] chartData in
                self?.marketChartData = chartData
                self?.prepareChartPoints(chartData)
            })
            .store(in: &cancellables)
    }
    
    private func prepareChartPoints(_ marketData: MarketChartData) {
        var points: [PricePoint] = []
        
        for dataPoint in marketData.prices {
            let timestamp = Date(timeIntervalSince1970: dataPoint[0] / 1000)
            let price = dataPoint[1]
            let formattedDate = formatDate(timestamp)
            
            let point = PricePoint(
                date: timestamp,
                price: price,
                formattedDate: formattedDate
            )
            
            points.append(point)
        }
        
        self.chartPoints = points
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    
    func refreshData() {
        if let id = cryptocurrency?.id {
            loadCryptocurrencyDetails(id: id)
        }
    }
}
