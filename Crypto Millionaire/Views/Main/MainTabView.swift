//
//  MainTabView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = MainTabViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            NavigationView {
                CryptocurrencyListView()
            }
            .tabItem {
                Label("Market", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(0)
            
            NavigationView {
                PortfolioView()
            }
            .tabItem {
                Label("Portfolio", systemImage: "briefcase")
            }
            .tag(1)
            
            NavigationView {
                RankingView()
            }
            .tabItem {
                Label("Ranking", systemImage: "trophy")
            }
            .tag(2)
            
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .accentColor(CryptoTheme.accent)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onChange(of: viewModel.selectedTab) { newValue, oldValue in
            viewModel.refreshAllData()
        }
    }
}

#Preview {
    MainTabView()
}
