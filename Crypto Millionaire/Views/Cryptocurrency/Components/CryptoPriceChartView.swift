//
//  CryptoPriceChartView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 10/04/2025.
//

import SwiftUI
import Charts

struct CryptoPriceChartView: View {
    @ObservedObject var viewModel: CryptocurrencyDetailsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(viewModel.cryptocurrency?.name ?? "Crypto") Price")
                .font(.headline)
            
            Text("Last 7 days")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if viewModel.chartPoints.isEmpty {
                ProgressView()
                    .frame(height: 250)
            } else {
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
            }
        }
        .padding()
    }
    
    private var minMaxPriceRange: ClosedRange<Double> {
        let prices = viewModel.chartPoints.map { $0.price }
        if let min = prices.min(), let max = prices.max() {
            // Add some padding to the range
            let padding = (max - min) * 0.1
            return (min - padding)...(max + padding)
        }
        return 0...100 // Default range if no data
    }
}

