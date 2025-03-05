//
//  FavoritesViewModel.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// ViewModels/FavoritesViewModel.swift (expanded)
import Foundation
import Combine

class FavoritesViewModel: ObservableObject {
    // Published state
    @Published private(set) var favoriteChannels: [Channel] = []
    @Published private(set) var favoriteMovies: [Movie] = []
    @Published private(set) var favoriteSeries: [Series] = []
    @Published private(set) var recentChannels: [Channel] = []
    @Published private(set) var recentMovies: [Movie] = []
    @Published private(set) var recentSeries: [Series] = []
    @Published private(set) var isLoading = false
    
    // Dependencies
    private let contentManager: ContentManager
    private let liveChannelsViewModel: LiveChannelsViewModel
    private let moviesViewModel: MoviesViewModel
    private let seriesViewModel: SeriesViewModel
    
    init(
        contentManager: ContentManager,
        liveChannelsViewModel: LiveChannelsViewModel,
        moviesViewModel: MoviesViewModel,
        seriesViewModel: SeriesViewModel
    ) {
        self.contentManager = contentManager
        self.liveChannelsViewModel = liveChannelsViewModel
        self.moviesViewModel = moviesViewModel
        self.seriesViewModel = seriesViewModel
    }
    
    // MARK: - Public Methods
    
    func refresh() {
        isLoading = true
        
        // Load favorites
        loadFavorites()
        
        // Load recently watched
        loadRecentlyWatched()
        
        isLoading = false
    }
    
    func removeFavorite(id: String) {
        contentManager.userPreferences.removeFromFavorites(contentID: id)
        refresh()
    }
    
    // MARK: - Private Methods
    
    private func loadFavorites() {
        // Get favorite IDs
        let favoriteIDs = contentManager.userPreferences.favorites
        
        // Get favorite channels
        favoriteChannels = liveChannelsViewModel.channels.filter {
            favoriteIDs.contains($0.id)
        }
        
        // Get favorite movies
        favoriteMovies = moviesViewModel.movies.filter {
            favoriteIDs.contains($0.id)
        }
        
        // Get favorite series
        favoriteSeries = seriesViewModel.seriesList.filter {
            favoriteIDs.contains($0.id)
        }
    }
    
    private func loadRecentlyWatched() {
        // Get recently watched IDs
        let recentIDs = contentManager.userPreferences.recentlyWatched
        
        // Get recent channels
        recentChannels = liveChannelsViewModel.channels.filter {
            recentIDs.contains($0.id)
        }
        
        // Get recent movies
        recentMovies = moviesViewModel.movies.filter {
            recentIDs.contains($0.id)
        }
        
        // Get recent series
        recentSeries = seriesViewModel.seriesList.filter {
            recentIDs.contains($0.id)
        }
    }
}
