//
//  ImageCache.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// ImageCache.swift
import UIKit
import Combine

class ImageCache {
    static let shared = ImageCache()
    
    // In-memory cache
    private let memoryCache = NSCache<NSString, UIImage>()
    
    // Disk cache
    private let diskCache: DiskCacheManager
    
    // Active downloads
    private var downloads: [URL: AnyPublisher<UIImage, Error>] = [:]
    
    private init() {
        // Set up memory cache with limits
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Set up disk cache
        diskCache = DiskCacheManager(cacheName: "ImageCache")
        
        // Register for memory warnings
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemoryCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        
        // Clean up expired items on init
        DispatchQueue.global(qos: .background).async {
            self.diskCache.cleanupExpired()
        }
    }
    
    // MARK: - Public Methods
    
    func image(for url: URL) -> UIImage? {
        let key = cacheKey(for: url)
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // Try to load from disk cache
        do {
            if let data = try diskCache.loadData(forKey: key),
               let image = UIImage(data: data) {
                // Store in memory cache for faster access next time
                memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
                return image
            }
        } catch {
            // Just log the error and continue
            print("Failed to load image from disk cache: \(error)")
        }
        
        return nil
    }
    
    func loadImage(from url: URL) -> AnyPublisher<UIImage, Error> {
        let key = cacheKey(for: url)
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return Just(cachedImage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Try to load from disk cache
        do {
            if let data = try diskCache.loadData(forKey: key),
               let image = UIImage(data: data) {
                // Store in memory cache for faster access next time
                memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
                return Just(image)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        } catch {
            // Just log the error and continue
            print("Failed to load image from disk cache: \(error)")
        }
        
        // Check if there's already a download in progress
        if let download = downloads[url] {
            return download
        }
        
        // Download the image
        let download = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> UIImage in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                
                guard let image = UIImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }
                
                return image
            }
            .handleEvents(
                receiveOutput: { [weak self] image in
                    guard let self = self else { return }
                    
                    // Save to memory cache
                    self.memoryCache.setObject(image, forKey: key as NSString, cost: image.jpegData(compressionQuality: 0.8)?.count ?? 0)
                    
                    // Save to disk cache on background thread
                    DispatchQueue.global(qos: .background).async {
                        if let data = image.jpegData(compressionQuality: 0.8) {
                            try? self.diskCache.saveData(data, forKey: key)
                        }
                    }
                },
                receiveCompletion: { [weak self] _ in
                    // Remove download when completed
                    self?.downloads[url] = nil
                },
                receiveCancel: { [weak self] in
                    // Remove download when cancelled
                    self?.downloads[url] = nil
                }
            )
            .share()
            .eraseToAnyPublisher()
        
        // Store the download task
        downloads[url] = download
        
        return download
    }
    
    func removeImage(for url: URL) {
        let key = cacheKey(for: url)
        memoryCache.removeObject(forKey: key as NSString)
        diskCache.remove(forKey: key)
    }
    
    func clearCache() {
        clearMemoryCache()
        diskCache.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func cacheKey(for url: URL) -> String {
        return url.absoluteString
    }
    
    @objc public func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }
}
