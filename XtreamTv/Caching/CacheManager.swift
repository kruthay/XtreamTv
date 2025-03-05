//
//  CacheManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// CacheManager.swift
import Foundation

protocol CacheManager {
    func save<T: Encodable>(object: T, forKey key: String) throws
    func load<T: Decodable>(forKey key: String) throws -> T?
    func saveData(_ data: Data, forKey key: String) throws
    func loadData(forKey key: String) throws -> Data?
    func remove(forKey key: String)
    func removeAll()
    func cleanupExpired()
}

enum CacheError: Error {
    case encodingFailed
    case decodingFailed
    case saveFailed
    case loadFailed
    case notFound
}
