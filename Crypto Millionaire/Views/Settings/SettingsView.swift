//
//  SettingsView.swift
//  Crypto Millionaire
//
//  Created by Hubert Wojtowicz on 09/04/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showResetAlert = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        balanceCard
                        
                        appearanceSettings
                        
                        dataSettings
                        
                        resetSection
                        
                        appInfoSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Reset Account"),
                    message: Text("This will reset your account to the initial balance of $10,000. All transactions will be lost. Are you sure?"),
                    primaryButton: .destructive(Text("Reset")) {
                        viewModel.resetAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var balanceCard: some View {
        GlassCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title2)
                        .foregroundColor(CryptoTheme.accent)
                    
                    Text("Your Balance")
                        .font(.headline)
                    
                    Spacer()
                }
                
                HStack(alignment: .firstTextBaseline) {
                    Text("$\(String(format: "%.2f", viewModel.userBalance?.balance ?? 0))")
                        .font(.system(size: 36, weight: .bold))
                    
                    Spacer()
                    
                    Button {
                        showResetAlert = true
                    } label: {
                        Text("Reset")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(CryptoTheme.red)
                            .cornerRadius(8)
                    }
                }
                
                Text("Starting balance: $\(String(format: "%.2f", viewModel.initialBalance))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var appearanceSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.headline)
            
            settingRow(icon: "moon.fill", color: .purple) {
                Toggle("Dark Mode", isOn: $isDarkMode)
                    .onChange(of: isDarkMode) { newValue, oldValue in
                        viewModel.darkMode = newValue
                        viewModel.saveSettings()
                    }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var dataSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Settings")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                        .frame(width: 30)
                    
                    Text("Auto Refresh")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(viewModel.refreshInterval) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Slider(value: Binding(
                    get: { Double(viewModel.refreshInterval) },
                    set: { viewModel.refreshInterval = Int($0) }
                ), in: 1...30, step: 1)
                .accentColor(.blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
            
            Button {
                showResetAlert = true
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(CryptoTheme.red)
                        .frame(width: 30)
                    
                    Text("Reset All Data")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("App Info")
                .font(.headline)
            
            VStack(spacing: 12) {
                infoRow(title: "Version", value: "1.0.0")
                infoRow(title: "Build", value: "1")
                infoRow(title: "Data Source", value: "CoinGecko API")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func settingRow<Content: View>(icon: String, color: Color, content: @escaping () -> Content) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 30)
            
            content()
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
        }
    }
}

#Preview {
    SettingsView()
}
