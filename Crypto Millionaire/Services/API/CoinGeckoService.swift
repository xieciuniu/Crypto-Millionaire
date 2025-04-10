//
//  CoinGecoService.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case apiError(String)
    case unknown
}

class CoinGeckoService {
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let apiKey: String
    private let jsonDecoder: JSONDecoder
    
    init(apiKey: String) {
        self.apiKey = apiKey
        jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
    // Pomocnicza metoda do dodawania klucza API do URL
    private func urlWithAPIKey(_ urlString: String) -> URL? {
        guard var components = URLComponents(string: urlString) else {
            return nil
        }
        
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "x_cg_demo_api_key", value: apiKey))
        components.queryItems = queryItems
        
        return components.url
    }
    
    func getCoins() -> AnyPublisher<[Cryptocurrency], Error> {
        let urlString = "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
        
        guard let url = urlWithAPIKey(urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                if httpResponse.statusCode == 429 {
                    throw NetworkError.apiError("Rate limit exceeded. Please try again later.")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: [Cryptocurrency].self, decoder: jsonDecoder)
            .mapError { error in
                if let decodingError = error as? DecodingError {
                    print("Decoding error: \(decodingError)")
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }
    
    func getCoinDetails(id: String) -> AnyPublisher<CryptocurrencyDetail, Error> {
        let urlString = "\(baseURL)/coins/\(id)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false"
        
        guard let url = urlWithAPIKey(urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                if httpResponse.statusCode == 429 {
                    throw NetworkError.apiError("Rate limit exceeded. Please try again later.")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: CryptocurrencyDetail.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
    
    func getCoinMarketChart(id: String, days: Int) -> AnyPublisher<MarketChartData, Error> {
        let urlString = "\(baseURL)/coins/\(id)/market_chart?vs_currency=usd&days=\(days)"
        
        guard let url = urlWithAPIKey(urlString) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                if httpResponse.statusCode == 429 {
                    throw NetworkError.apiError("Rate limit exceeded. Please try again later.")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.httpError(httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: MarketChartData.self, decoder: jsonDecoder)
            .eraseToAnyPublisher()
    }
}

struct CryptocurrencyDetail: Codable {
    let id: String
    let symbol: String
    let name: String
    let description: [String: String]
    let image: ImageLinks
    let marketData: MarketData
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, description, image
        case marketData = "market_data"
    }
    
    struct ImageLinks: Codable {
        let thumb: String
        let small: String
        let large: String
    }
    
    struct MarketData: Codable {
        let currentPrice: [String: Double]
        let marketCap: [String: Double]
        let marketCapRank: Int
        let priceChangePercentage24h: Double?
        let priceChangePercentage7d: Double?
        let priceChangePercentage30d: Double?
        let high24h: [String: Double]?
        let low24h: [String: Double]?
        
        enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
            case marketCap = "market_cap"
            case marketCapRank = "market_cap_rank"
            case priceChangePercentage24h = "price_change_percentage_24h"
            case priceChangePercentage7d = "price_change_percentage_7d"
            case priceChangePercentage30d = "price_change_percentage_30d"
            case high24h = "high_24h"
            case low24h = "low_24h"
        }
    }
}

struct MarketChartData: Codable {
    let prices: [[Double]]
    let marketCaps: [[Double]]
    let totalVolumes: [[Double]]
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}
