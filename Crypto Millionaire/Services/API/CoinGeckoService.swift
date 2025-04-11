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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
    }
    
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
        print(urlString)
        
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
    
//    func debugGetCoins() {
//        let urlString = "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false"
//        
//        guard var components = URLComponents(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        var queryItems = components.queryItems ?? []
//        queryItems.append(URLQueryItem(name: "x_cg_demo_api_key", value: apiKey))
//        components.queryItems = queryItems
//        
//        guard let url = components.url else {
//            print("Failed to create URL")
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Network error: \(error)")
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else {
//                print("Invalid response type")
//                return
//            }
//            
//            print("Status code: \(httpResponse.statusCode)")
//            
//            guard let data = data else {
//                print("No data received")
//                return
//            }
//            
//            do {
//                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
//                   let firstItem = jsonArray.first {
//                    print("API returned keys: \(firstItem.keys.sorted())")
//                    
//                    for (key, value) in firstItem {
//                        print("Key: \(key), Type: \(type(of: value))")
//                    }
//                } else {
//                    print("Failed to parse JSON as array of dictionaries")
//                    if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                        print("API error response: \(errorResponse)")
//                    }
//                }
//                
//                // Teraz spróbuj zdekodować do Twojego modelu
//                let cryptocurrencies = try self.jsonDecoder.decode([Cryptocurrency].self, from: data)
//                print("Successfully decoded \(cryptocurrencies.count) cryptocurrencies")
//                if let first = cryptocurrencies.first {
//                    print("First item: \(first)")
//                }
//            } catch {
//                print("JSON parsing error: \(error)")
//                if let decodingError = error as? DecodingError {
//                    switch decodingError {
//                    case .keyNotFound(let key, let context):
//                        print("Key not found: \(key), context: \(context)")
//                    case .typeMismatch(let type, let context):
//                        print("Type mismatch: expected \(type), context: \(context)")
//                    case .valueNotFound(let type, let context):
//                        print("Value not found: \(type), context: \(context)")
//                    case .dataCorrupted(let context):
//                        print("Data corrupted: \(context)")
//                    @unknown default:
//                        print("Unknown decoding error")
//                    }
//                }
//            }
//        }
//        .resume()
//    }
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
