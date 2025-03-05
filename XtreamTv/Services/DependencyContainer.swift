//
//  DependencyContainer.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// DependencyContainer.swift
// DependencyContainer.swift (updated)
import Foundation

class DependencyContainer {
    // Core services
    let authManager: AuthManager
    let networkClient: NetworkClient
    
    // Content services
    let xtreamService: XtreamService
    let mediaStreamProvider: MediaStreamProvider
    let contentManager: ContentManager
    let userPreferences: UserPreferencesManager
    let mediaPlaybackService: MediaPlaybackService
    
    // Repositories
    let liveChannelsRepository: LiveChannelsRepository
    let moviesRepository: MoviesRepository
    let seriesRepository: SeriesRepository
    
    // ViewModels
    let authViewModel: AuthViewModel
    let liveChannelsViewModel: LiveChannelsViewModel
    let moviesViewModel: MoviesViewModel
    let seriesViewModel: SeriesViewModel
    let searchViewModel: SearchViewModel
    let favoritesViewModel: FavoritesViewModel
    
    init() {
        // Initialize core services
        networkClient = NetworkClient()
        authManager = AuthManager(networkClient: networkClient)
        
        // Initialize content services
        xtreamService = XtreamService(networkClient: networkClient, authManager: authManager)
        mediaStreamProvider = XtreamMediaStreamProvider(authManager: authManager)
        userPreferences = UserPreferencesManager()
        
        // Initialize repositories
        liveChannelsRepository = LiveChannelsRepository(service: xtreamService)
        moviesRepository = MoviesRepository(service: xtreamService)
        seriesRepository = SeriesRepository(service: xtreamService)
        
        // Initialize content manager
        contentManager = ContentManager(
            service: xtreamService,
            authManager: authManager,
            liveChannels: liveChannelsRepository,
            movies: moviesRepository,
            series: seriesRepository,
            userPreferences: userPreferences
        )
        
        // Initialize media playback service
        mediaPlaybackService = MediaPlaybackService(
            backgroundPlaybackManager: BackgroundPlaybackManager.shared,
            userPreferences: userPreferences
        )
        
        // Initialize ViewModels
        authViewModel = AuthViewModel(
            authManager: authManager,
            contentManager: contentManager
        )
        
        liveChannelsViewModel = LiveChannelsViewModel(
            channelsRepository: liveChannelsRepository,
            userPreferences: userPreferences,
            mediaStreamProvider: mediaStreamProvider
        )
        
        moviesViewModel = MoviesViewModel(
            moviesRepository: moviesRepository,
            userPreferences: userPreferences,
            mediaStreamProvider: mediaStreamProvider
        )
        
        seriesViewModel = SeriesViewModel(
            seriesRepository: seriesRepository,
            userPreferences: userPreferences,
            mediaStreamProvider: mediaStreamProvider
        )
        
        searchViewModel = SearchViewModel(
            contentManager: contentManager
        )
        
        // FavoritesViewModel needs to be initialized after the other ViewModels
        favoritesViewModel = FavoritesViewModel(
            contentManager: contentManager,
            liveChannelsViewModel: liveChannelsViewModel,
            moviesViewModel: moviesViewModel,
            seriesViewModel: seriesViewModel
        )
    }
}
