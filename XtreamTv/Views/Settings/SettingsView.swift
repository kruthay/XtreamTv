//
//  SettingsView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//
// Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingLogoutConfirmation = false
    @State private var showingCacheClearConfirmation = false
    @State private var debugModeEnabled = false
    @State private var cacheSize = "Calculating..."
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Button(action: {
                        showingLogoutConfirmation = true
                    }) {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("Cache")) {
                    HStack {
                        Text("Image Cache Size")
                        Spacer()
                        Text(cacheSize)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingCacheClearConfirmation = true
                    }) {
                        Label("Clear Cache", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown")
                            .foregroundColor(.secondary)
                    }
                }
                Section(header: Text("Developer")) {
                                    Toggle("Debug Mode", isOn: $debugModeEnabled)
                                        .onChange(of: debugModeEnabled) { oldValue, newValue in
                                            UserDefaults.standard.set(newValue, forKey: "debugModeEnabled")
                                            // Notify any observers if needed
                                        }
                                    
                                    if debugModeEnabled {
                                        NavigationLink("Debug Menu", destination: DebugMenuView())
                                    }
                                }
            }
            .navigationTitle("Settings")
            .onAppear {
                calculateCacheSize()
                debugModeEnabled = UserDefaults.standard.bool(forKey: "debugModeEnabled")

            }
            .alert(isPresented: $showingLogoutConfirmation) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        authViewModel.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
            .actionSheet(isPresented: $showingCacheClearConfirmation) {
                ActionSheet(
                    title: Text("Clear Cache"),
                    message: Text("Are you sure you want to clear all cached data? This cannot be undone."),
                    buttons: [
                        .destructive(Text("Clear All Cached Data")) {
                            clearAllCaches()
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    private func calculateCacheSize() {
        Task {
            // Get image cache size
            let imageCacheSize = ContentCacheManager.shared.getCacheSize()
            
            // Format size
            let formattedSize = ContentCacheManager.shared.formatSize(imageCacheSize)
            
            await MainActor.run {
                self.cacheSize = formattedSize
            }
        }
    }
    
    private func clearAllCaches() {
        // Clear all caches
        ImageCache.shared.clearCache()
        ContentCacheManager.shared.cleanupCache()
        
        // Update cache size display
        calculateCacheSize()
    }
}

