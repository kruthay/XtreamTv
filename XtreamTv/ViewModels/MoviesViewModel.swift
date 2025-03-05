//
//  MoviesViewModel.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class MoviesViewModel: ObservableObject {
    // Published state
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Dependencies
    private let moviesRepository: MoviesRepository
    private let userPreferences: UserPreferencesManager
    private let mediaStreamProvider: MediaStreamProvider
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(
        moviesRepository: MoviesRepository,
        userPreferences: UserPreferencesManager,
        mediaStreamProvider: MediaStreamProvider
    ) {
        self.moviesRepository = moviesRepository
        self.userPreferences = userPreferences
        self.mediaStreamProvider = mediaStreamProvider
        
        // Observe repository state
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to repository state
        moviesRepository.$movies
            .assign(to: &$movies)
        
        moviesRepository.$categories
            .assign(to: &$categories)
        
        moviesRepository.$isLoading
            .assign(to: &$isLoading)
        
        moviesRepository.$error
            .assign(to: &$error)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        await moviesRepository.loadData()
    }
    
    func getMoviesForCategory(_ categoryID: String?) -> [Movie] {
        if let categoryID = categoryID {
            return moviesRepository.moviesForCategory(categoryID)
        } else {
            return movies
        }
    }
    
    func getMovie(by id: String) -> Movie? {
        return moviesRepository.getMovie(byID: id)
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return moviesRepository.getCategoryName(for: categoryID)
    }
    
    func createMediaItem(from movie: Movie) -> MediaItem? {
        return MediaItem.fromMovie(
            movie: movie,
            streamProvider: mediaStreamProvider
        )
    }
    
    func isFavorite(movieID: String) -> Bool {
        return userPreferences.isFavorite(contentID: movieID)
    }
    
    func toggleFavorite(movieID: String) {
        userPreferences.toggleFavorite(contentID: movieID)
    }
    
    func addToRecentlyWatched(movieID: String) {
        userPreferences.addToRecentlyWatched(contentID: movieID)
    }
}
