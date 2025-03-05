//
//  DiskCacheManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// DiskCacheManager.swift
import Foundation
import CryptoKit

class DiskCacheManager: CacheManager {
    private let fileManager: FileManager
    private let cacheDirectory: URL
    private let expirationInterval: TimeInterval
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    /// Initializes the disk cache manager
    /// - Parameters:
    ///   - cacheName: The name of the cache directory
    ///   - expirationInterval: Time in seconds after which cached items expire (default: 7 days)
    init(cacheName: String, expirationInterval: TimeInterval = 7 * 24 * 60 * 60) {
        self.fileManager = FileManager.default
        self.expirationInterval = expirationInterval
        
        // Get cache directory
        let cacheDirectories = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = cacheDirectories[0].appendingPathComponent(cacheName, isDirectory: true)
        
        // Create directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Metadata Management
    
    private func metadataURL(forKey key: String) -> URL {
        let fileName = normalizedFileName(for: key) + ".metadata"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func dataURL(forKey key: String) -> URL {
        let fileName = normalizedFileName(for: key) + ".data"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    private func saveMetadata(forKey key: String) throws {
        let metadata = CacheMetadata(creationDate: Date())
        let data = try encoder.encode(metadata)
        try data.write(to: metadataURL(forKey: key))
    }
    
    private func loadMetadata(forKey key: String) -> CacheMetadata? {
        let url = metadataURL(forKey: key)
        guard let data = try? Data(contentsOf: url),
              let metadata = try? decoder.decode(CacheMetadata.self, from: data) else {
            return nil
        }
        return metadata
    }
    
    private func isExpired(metadata: CacheMetadata) -> Bool {
        let expirationDate = metadata.creationDate.addingTimeInterval(expirationInterval)
        return Date() > expirationDate
    }
    
    // MARK: - Helper Methods
    
    private func normalizedFileName(for key: String) -> String {
        // Create a safe filename from the key
        let sanitizedKey = key.components(separatedBy: .urlHostAllowed.inverted).joined()
        
        // If the key is too long, hash it
        if sanitizedKey.count > 50 {
            return sanitizedKey.md5Hash
        }
        
        return sanitizedKey
    }
    
    // MARK: - CacheManager Protocol Implementation
    
    func save<T: Encodable>(object: T, forKey key: String) throws {
        let data = try encoder.encode(object)
        try saveData(data, forKey: key)
    }
    
    func load<T: Decodable>(forKey key: String) throws -> T? {
        guard let data = try loadData(forKey: key) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw CacheError.decodingFailed
        }
    }
    
    func saveData(_ data: Data, forKey key: String) throws {
        let dataURL = self.dataURL(forKey: key)
        
        do {
            try data.write(to: dataURL)
            try saveMetadata(forKey: key)
        } catch {
            throw CacheError.saveFailed
        }
    }
    
    func loadData(forKey key: String) throws -> Data? {
        let dataURL = self.dataURL(forKey: key)
        let metadataURL = self.metadataURL(forKey: key)
        
        // Check if file exists
        guard fileManager.fileExists(atPath: dataURL.path),
              fileManager.fileExists(atPath: metadataURL.path) else {
            return nil
        }
        
        // Check if expired
        guard let metadata = loadMetadata(forKey: key), !isExpired(metadata: metadata) else {
            // Remove expired item
            remove(forKey: key)
            return nil
        }
        
        // Load data
        do {
            return try Data(contentsOf: dataURL)
        } catch {
            throw CacheError.loadFailed
        }
    }
    
    func remove(forKey key: String) {
        let dataURL = self.dataURL(forKey: key)
        let metadataURL = self.metadataURL(forKey: key)
        
        try? fileManager.removeItem(at: dataURL)
        try? fileManager.removeItem(at: metadataURL)
    }
    
    func removeAll() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func cleanupExpired() {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return
        }
        
        // Get metadata files
        let metadataURLs = fileURLs.filter { $0.lastPathComponent.hasSuffix(".metadata") }
        
        for metadataURL in metadataURLs {
            let key = metadataURL.lastPathComponent
                .replacingOccurrences(of: ".metadata", with: "")
            
            // Check if metadata is expired
            if let metadata = loadMetadata(forKey: key), isExpired(metadata: metadata) {
                remove(forKey: key)
            }
        }
    }
    
    // MARK: - Cache Statistics
    
    func cacheSize() -> Int {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }
        
        return fileURLs.reduce(0) { totalSize, url in
            let fileSize = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return totalSize + fileSize
        }
    }
    
    func itemCount() -> Int {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: nil
        ) else {
            return 0
        }
        
        // Count only data files
        return fileURLs.filter { $0.lastPathComponent.hasSuffix(".data") }.count
    }
}

// Helper struct for cache metadata
private struct CacheMetadata: Codable {
    let creationDate: Date
}

// String extension for creating MD5 hash


extension String {
    var md5Hash: String {
        let inputData = Data(self.utf8)
        let hashed = Insecure.MD5.hash(data: inputData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

// Import for MD5 hashing
import CommonCrypto
