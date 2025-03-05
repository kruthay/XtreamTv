//
//  SeriesViewModel.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class SeriesViewModel: ObservableObject {
    // Published state
    @Published private(set) var seriesList: [Series] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Dependencies
    private let seriesRepository: SeriesRepository
    private let userPreferences: UserPreferencesManager
    private let mediaStreamProvider: MediaStreamProvider
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(
        seriesRepository: SeriesRepository,
        userPreferences: UserPreferencesManager,
        mediaStreamProvider: MediaStreamProvider
    ) {
        self.seriesRepository = seriesRepository
        self.userPreferences = userPreferences
        self.mediaStreamProvider = mediaStreamProvider
        
        // Observe repository state
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to repository state
        seriesRepository.$series
            .assign(to: &$seriesList)
        
        seriesRepository.$categories
            .assign(to: &$categories)
        
        seriesRepository.$isLoading
            .assign(to: &$isLoading)
        
        seriesRepository.$error
            .assign(to: &$error)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        await seriesRepository.loadData()
    }
    
    func getSeriesForCategory(_ categoryID: String?) -> [Series] {
        if let categoryID = categoryID {
            return seriesRepository.seriesForCategory(categoryID)
        } else {
            return seriesList
        }
    }
    
    func getSeries(by id: String) -> Series? {
        return seriesRepository.getSeries(byID: id)
    }
    
    func getSeriesInfo(seriesID: String) async throws -> SeriesInfo {
        return try await seriesRepository.getSeriesInfo(seriesID: seriesID)
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return seriesRepository.getCategoryName(for: categoryID)
    }
    
    func createMediaItem(
        from episode: Episode,
        seriesName: String
    ) -> MediaItem? {
        return MediaItem.fromEpisode(
            episode: episode,
            seriesName: seriesName,
            streamProvider: mediaStreamProvider
        )
    }
    
    func isFavorite(seriesID: String) -> Bool {
        return userPreferences.isFavorite(contentID: seriesID)
    }
    
    func toggleFavorite(seriesID: String) {
        userPreferences.toggleFavorite(contentID: seriesID)
    }
    
    func addToRecentlyWatched(seriesID: String) {
        userPreferences.addToRecentlyWatched(contentID: seriesID)
    }
}

