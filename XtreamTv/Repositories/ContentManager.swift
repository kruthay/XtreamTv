//
//  ContentManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// ContentManager.swift
import Foundation
import Combine

class ContentManager: ObservableObject {
    // Published state
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Repositories
    let liveChannels: LiveChannelsRepository
    let movies: MoviesRepository
    let series: SeriesRepository
    let userPreferences: UserPreferencesManager
    
    // Dependencies
    private let service: XtreamService
    private let authManager: AuthManager
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(
        service: XtreamService,
        authManager: AuthManager,
        liveChannels: LiveChannelsRepository? = nil,
        movies: MoviesRepository? = nil,
        series: SeriesRepository? = nil,
        userPreferences: UserPreferencesManager? = nil
    ) {
        self.service = service
        self.authManager = authManager
        
        // Initialize repositories
        self.liveChannels = liveChannels ?? LiveChannelsRepository(service: service)
        self.movies = movies ?? MoviesRepository(service: service)
        self.series = series ?? SeriesRepository(service: service)
        self.userPreferences = userPreferences ?? UserPreferencesManager()
        
        // Set up observation of loading states
        setupStateObservation()
    }
    
    private func setupStateObservation() {
        // Combine loading states from all repositories
        Publishers.CombineLatest3(
            liveChannels.$isLoading,
            movies.$isLoading,
            series.$isLoading
        )
        .map { liveLoading, moviesLoading, seriesLoading in
            return liveLoading || moviesLoading || seriesLoading
        }
        .assign(to: &$isLoading)
        
        // Observe errors from all repositories
        liveChannels.$error
            .compactMap { $0 }
            .assign(to: &$error)
        
        movies.$error
            .compactMap { $0 }
            .assign(to: &$error)
        
        series.$error
            .compactMap { $0 }
            .assign(to: &$error)
    }
    
    // MARK: - Data Loading
    
    func loadAllData() async {
        guard authManager.isAuthenticated else {
            await MainActor.run {
                self.error = NetworkError.authenticationRequired
            }
            return
        }
        
        await withTaskGroup(of: Void.self) { group in
            // Load data from all repositories concurrently
            group.addTask {
                await self.liveChannels.loadData()
            }
            
            group.addTask {
                await self.movies.loadData()
            }
            
            group.addTask {
                await self.series.loadData()
            }
        }
    }
    
    // MARK: - Favorites Management
    
    func getFavoriteChannels() -> [Channel] {
        let favoriteIDs = userPreferences.favorites
        return liveChannels.channels.filter { favoriteIDs.contains($0.id) }
    }
    
    func getFavoriteMovies() -> [Movie] {
        let favoriteIDs = userPreferences.favorites
        return movies.movies.filter { favoriteIDs.contains($0.id) }
    }
    
    func getFavoriteSeries() -> [Series] {
        let favoriteIDs = userPreferences.favorites
        return series.series.filter { favoriteIDs.contains($0.id) }
    }
    
    // MARK: - Recently Watched Management
    
    func getRecentlyWatchedChannels() -> [Channel] {
        let recentIDs = userPreferences.recentlyWatched
        return liveChannels.channels.filter { recentIDs.contains($0.id) }
    }
    
    func getRecentlyWatchedMovies() -> [Movie] {
        let recentIDs = userPreferences.recentlyWatched
        return movies.movies.filter { recentIDs.contains($0.id) }
    }
    
    func getRecentlyWatchedSeries() -> [Series] {
        let recentIDs = userPreferences.recentlyWatched
        return series.series.filter { recentIDs.contains($0.id) }
    }
    
    // MARK: - Search
    
    func search(query: String) -> (channels: [Channel], movies: [Movie], series: [Series]) {
        let channelResults = liveChannels.searchChannels(query: query)
        let movieResults = movies.searchMovies(query: query)
        let seriesResults = series.searchSeries(query: query)
        
        return (channelResults, movieResults, seriesResults)
    }
}
