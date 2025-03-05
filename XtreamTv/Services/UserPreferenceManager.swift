//
//  UserPreferenceManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// UserPreferencesManager.swift
import Foundation
import Combine

class UserPreferencesManager: ObservableObject {
    // Published properties for UI updates
    @Published private(set) var favorites: [String] = []
    @Published private(set) var recentlyWatched: [String] = []
    
    // Storage
    private let userDefaults: UserDefaults
    
    // Maximum number of recently watched items to keep
    private let maxRecentItems = 20
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadPreferences()
    }
    
    // MARK: - Loading Preferences
    
    private func loadPreferences() {
        loadFavorites()
        loadRecentlyWatched()
    }
    
    private func loadFavorites() {
        if let savedFavorites = userDefaults.stringArray(forKey: "favorites") {
            favorites = savedFavorites
        }
    }
    
    private func loadRecentlyWatched() {
        if let savedRecent = userDefaults.stringArray(forKey: "recentlyWatched") {
            recentlyWatched = savedRecent
        }
    }
    
    // MARK: - Saving Preferences
    
    private func saveFavorites() {
        userDefaults.set(favorites, forKey: "favorites")
    }
    
    private func saveRecentlyWatched() {
        userDefaults.set(recentlyWatched, forKey: "recentlyWatched")
    }
    
    // MARK: - Favorites Management
    
    func addToFavorites(contentID: String) {
        if !favorites.contains(contentID) {
            favorites.append(contentID)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(contentID: String) {
        favorites.removeAll { $0 == contentID }
        saveFavorites()
    }
    
    func toggleFavorite(contentID: String) {
        if favorites.contains(contentID) {
            removeFromFavorites(contentID: contentID)
        } else {
            addToFavorites(contentID: contentID)
        }
    }
    
    func isFavorite(contentID: String) -> Bool {
        return favorites.contains(contentID)
    }
    
    // MARK: - Recently Watched Management
    
    func addToRecentlyWatched(contentID: String) {
        // Remove if exists to avoid duplicates
        if let index = recentlyWatched.firstIndex(of: contentID) {
            recentlyWatched.remove(at: index)
        }
        
        // Add to the beginning of the list
        recentlyWatched.insert(contentID, at: 0)
        
        // Trim list if needed
        if recentlyWatched.count > maxRecentItems {
            recentlyWatched = Array(recentlyWatched.prefix(maxRecentItems))
        }
        
        saveRecentlyWatched()
    }
    
    func clearRecentlyWatched() {
        recentlyWatched.removeAll()
        saveRecentlyWatched()
    }
}
