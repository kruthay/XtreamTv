//
//  DebugMenuView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/Debug/DebugMenuView.swift
import SwiftUI

#if DEBUG
struct DebugMenuView: View {
    @State private var logs: [String] = []
    @State private var showingNetworkTester = false
    @State private var selectedLogLevel: LogLevel = .debug
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Debug Tools")) {
                    NavigationLink("Network Tester", destination: URLTestingView())
                    NavigationLink("Stream URL Tester", destination: URLTesterView())
                    NavigationLink("Cache Manager", destination: CacheInfoView())
                }
                
                Section(header: Text("Logging")) {
                    Picker("Minimum Log Level", selection: $selectedLogLevel) {
                        Text("Debug").tag(LogLevel.debug)
                        Text("Info").tag(LogLevel.info)
                        Text("Warning").tag(LogLevel.warning)
                        Text("Error").tag(LogLevel.error)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: selectedLogLevel) { oldValue, newValue in
                        Logger.shared.setMinimumLogLevel(newValue)
                    }
                    
                    Button("Clear Logs") {
                        Logger.shared.clearInMemoryLogs()
                        refreshLogs()
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Application Logs")) {
                    if logs.isEmpty {
                        Text("No logs to display")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(logs, id: \.self) { log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                        }
                    }
                }
            }
            .navigationTitle("Debug Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshLogs) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                refreshLogs()
            }
        }
    }
    
    private func refreshLogs() {
        logs = Logger.shared.getInMemoryLogs()
    }
}

struct CacheInfoView: View {
    @State private var imageCount = 0
    @State private var cacheSize = ""
    @State private var isRefreshing = false
    @State private var showingClearConfirmation = false
    
    var body: some View {
        List {
            Section(header: Text("Cache Statistics")) {
                HStack {
                    Text("Image Cache Size")
                    Spacer()
                    Text(cacheSize)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Cached Items")
                    Spacer()
                    Text("\(imageCount)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button(action: {
                    refreshCacheInfo()
                }) {
                    HStack {
                        Text("Refresh Cache Info")
                        Spacer()
                        if isRefreshing {
                            ProgressView()
                        }
                    }
                }
                
                Button(action: {
                    showingClearConfirmation = true
                }) {
                    Text("Clear Image Cache")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Cache Info")
        .onAppear {
            refreshCacheInfo()
        }
        .alert(isPresented: $showingClearConfirmation) {
            Alert(
                title: Text("Clear Cache"),
                message: Text("Are you sure you want to clear the image cache? This cannot be undone."),
                primaryButton: .destructive(Text("Clear")) {
                    clearCache()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func refreshCacheInfo() {
        isRefreshing = true
        
        Task {
            let cacheInfo = await getCacheInfo()
            
            DispatchQueue.main.async {
                self.cacheSize = cacheInfo.sizeString
                self.imageCount = cacheInfo.count
                self.isRefreshing = false
            }
        }
    }
    
    private func getCacheInfo() async -> (sizeString: String, count: Int) {
        // Get cache info - this is a placeholder for actual implementation
        let size = ContentCacheManager.shared.getCacheSize()
        let count = ContentCacheManager.shared.getItemCount()
        let sizeString = ContentCacheManager.shared.formatSize(size)
        
        return (sizeString, count)
    }
    
    private func clearCache() {
        Task {
            // Clear cache
            ImageCache.shared.clearCache()
            
            // Refresh info
            refreshCacheInfo()
        }
    }
}
#endif
