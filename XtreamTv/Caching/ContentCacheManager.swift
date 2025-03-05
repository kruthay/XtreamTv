//
//  ContentCacheManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
// ContentCacheManager.swift
import Foundation

class ContentCacheManager {
    static let shared = ContentCacheManager()
    
    // Disk cache
    private let diskCache: DiskCacheManager
    
    // Maximum cache size in bytes (100MB by default)
    private let maxCacheSize: Int = 100_000_000
    
    // Container extension mapping
    private var containerExtensionMap: [String: String] = [:]
    
    private init() {
        // Set up disk cache with 30-day expiration
        diskCache = DiskCacheManager(
            cacheName: "ContentCache",
            expirationInterval: 30 * 24 * 60 * 60
        )
        
        // Load container extension map
        loadContainerExtensionMap()
        
        // Clean up cache on init
        cleanupCache()
    }
    
    // MARK: - Container Extensions
    
    func saveContainerExtensions(for vodItems: [Movie]) {
        // Create a map of streamID to containerExtension
        let extensionMap = vodItems.reduce(into: [String: String]()) { map, vod in
            map[vod.streamID] = vod.containerExtension
        }
        
        containerExtensionMap = extensionMap
        
        // Save to disk
        try? diskCache.save(object: extensionMap, forKey: "container_extensions")
    }
    
    func getContainerExtension(for vodID: String) -> String {
        return containerExtensionMap[vodID] ?? "mp4"
    }
    
    private func loadContainerExtensionMap() {
        if let map: [String: String] = try? diskCache.load(forKey: "container_extensions") {
            containerExtensionMap = map
        }
    }
    
    // MARK: - Cache Management
    
    func cleanupCache() {
        // Cleanup expired items first
        diskCache.cleanupExpired()
        
        // Check if cache exceeds size limit
        let cacheSize = diskCache.cacheSize()
        if cacheSize > maxCacheSize {
            reduceCache(to: maxCacheSize / 2)
        }
    }
    
    private func reduceCache(to targetSize: Int) {
        // TODO: Implement a more sophisticated cache reduction algorithm
        // For now, just clear everything if we're over the limit
        diskCache.removeAll()
    }
    
    // MARK: - Cache Statistics
    
    func getCacheSize() -> Int {
        return diskCache.cacheSize()
    }
    
    func getItemCount() -> Int {
        return diskCache.itemCount()
    }
    
    func formatSize(_ size: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
}
