//
//  CryptocurrencyDetailViewModel.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import Combine
import SwiftUICharts

// View model for CryptocurrencyDetails view.
// manages details data for a single cryptocurrency and trading operations

class CryptocurrencyDetailViewModel: ObservableObject {
    @Published var cryptocurrency: CryptocurrencyDetail? = nil
    @Published var marketChartData: MarketChartData? = nil
    // MARK: SwiftUICharts implementation to change
    @Published var chartData: ChartData? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var tradeSuccess: Bool? = nil
    @Published var userBalance: UserBalance? = nil
    @Published var portfolioQuantity: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    private var coinGeckoService: CoinGeckoService
    private let databaseManager = DatabaseManager.shared
    
    init(apiKey: String = ApiConfig.coinGeckoApiKey) {
        self.coinGeckoService = CoinGeckoService(apiKey: apiKey)
    }
    
    // Loads details for a specific cryptocurrency
    func loadCryptocurrencyDetails(id: String) {
        isLoading = true
        errorMessage = nil
        
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
    
    //Loads portfolio data for this cryptocurrency
    private func loadPortfolioInfo(cryptoId: String) {
        let portfolio = databaseManager.getPortfolio()
        if let portfolioItem = portfolio.first(where: { $0.cryptoId == cryptoId}) {
            portfolioQuantity = portfolioItem.quantity
        } else {
            portfolioQuantity = 0
        }
    }
    
    // Loads price chart data for the cryptocurrency
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
//                self?.prepareChartData(chartData)
            })
            .store(in: &cancellables)
    }
    
//    // Convert raw chart data to SwiftUICharts format
//    private func prepareChartData(_ marketData: MarketChartData) {
//        let points = marketData.prices.map { dataPoint -> LineChartDataPoint in
//            let timestamp = Date(timeIntervalSince1970: datePoint[0] / 1000)
//            let price = datePoint[1]
//            return ChartDataPoint(value: price, xAxisLabel: formatDate(timestamp), description: "$\(String(format: "%.2f", price))")
//        }
//        
////        let dataset
//    }
}
