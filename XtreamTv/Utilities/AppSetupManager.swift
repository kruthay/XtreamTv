//
//  AppSetupManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// AppSetupManager.swift
import Foundation
import AVFoundation
import UIKit

class AppSetupManager {
    static let shared = AppSetupManager()
    
    init() {}
    
    func setupApp() {
        // Configure subsystems in order
        configureLogging()
        configureAudioSession()
        configureURLCache()
        configureAppearance()
        scheduleBackgroundTasks()
        
        // Log app launch info
        logAppLaunchInfo()
    }
    
    private func configureLogging() {
        // Initialize logger with appropriate settings
        #if DEBUG
        Logger.shared.setMinimumLogLevel(.debug)
        #else
        Logger.shared.setMinimumLogLevel(.info)
        #endif
        
        logInfo("Logging system initialized", category: .general)
    }
    
    private func configureAudioSession() {
        do {
            // Configure audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            logInfo("Audio session configured successfully", category: .playback)
        } catch {
            logError(error, message: "Failed to configure audio session", category: .playback)
        }
    }
    
    private func configureURLCache() {
        // Configure URL caching for better performance
        let cacheSizeMemory = 20 * 1024 * 1024  // 20 MB
        let cacheSizeDisk = 100 * 1024 * 1024   // 100 MB
        let urlCache = URLCache(memoryCapacity: cacheSizeMemory, diskCapacity: cacheSizeDisk, diskPath: "URLCache")
        URLCache.shared = urlCache
        
        // Configure URL session defaults
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0
        config.timeoutIntervalForResource = 60.0
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 10
        
        logInfo("URL cache configured: \(ByteCountFormatter.string(fromByteCount: Int64(cacheSizeMemory), countStyle: .file)) memory, \(ByteCountFormatter.string(fromByteCount: Int64(cacheSizeDisk), countStyle: .file)) disk", category: .network)
    }
    
    private func configureAppearance() {
        // Configure UI appearance
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        // Configure tab bar appearance
        UITabBar.appearance().tintColor = UIColor.systemBlue
        
        logInfo("UI appearance configured", category: .ui)
    }
    
    private func scheduleBackgroundTasks() {
        // Schedule cleanup tasks
        Task {
            // Clean caches on startup
            ContentCacheManager.shared.cleanupCache()
            ImageCache.shared.clearMemoryCache()
            
            logInfo("Initial cache cleanup performed", category: .cache)
        }
        
        // Register for notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackgrounding),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleAppBackgrounding() {
        logInfo("App entering background", category: .general)
        
        // Save any pending data
        
        // Perform light cleanup
        ImageCache.shared.clearMemoryCache()
        
        // Stop any unnecessary processing
    }
    
    @objc private func handleAppForeground() {
        logInfo("App entering foreground", category: .general)
        
        // Refresh data if needed
        
        // Reconnect to services if needed
    }
    
    @objc private func handleMemoryWarning() {
        logWarning("Memory warning received", category: .general)
        
        // Clear memory caches
        ImageCache.shared.clearMemoryCache()
        
        // Cancel any non-essential operations
    }
    
    private func logAppLaunchInfo() {
        // Log app and device information
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        let deviceModel = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        
        logInfo("App launched: v\(appVersion) (\(buildNumber)) on \(deviceModel) iOS \(systemVersion)", category: .general)
    }
}
