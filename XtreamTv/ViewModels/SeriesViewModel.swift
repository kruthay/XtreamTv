// SeriesViewModel.swift
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
    
    // Cache
    private let cacheManager: DiskCacheManager
    private let seriesCacheKey = "cached_series"
    private let categoriesCacheKey = "cached_series_categories"
    
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
        
        // Initialize cache manager (1-day expiration, adjust as needed)
        self.cacheManager = DiskCacheManager(
            cacheName: "SeriesViewModelCache",
            expirationInterval: 24 * 60 * 60
        )
        
        // Attempt to load from cache first
        loadFromCache()
        
        // Observe repository state
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to repository state
        seriesRepository.$series
            .sink { [weak self] newSeries in
                self?.seriesList = newSeries
                self?.saveSeriesToCache(newSeries)
            }
            .store(in: &cancellables)
        
        seriesRepository.$categories
            .sink { [weak self] newCategories in
                self?.categories = newCategories
                self?.saveCategoriesToCache(newCategories)
            }
            .store(in: &cancellables)
        
        seriesRepository.$isLoading
            .assign(to: &$isLoading)
        
        seriesRepository.$error
            .assign(to: &$error)
    }
    
    // MARK: - Cache Methods
    
    private func loadFromCache() {
        // Load cached categories
        if let cachedCategories: [Category] = try? cacheManager.load(forKey: categoriesCacheKey) {
            self.categories = cachedCategories
        }
        // Load cached series
        if let cachedSeries: [Series] = try? cacheManager.load(forKey: seriesCacheKey) {
            self.seriesList = cachedSeries
        }
    }
    
    private func saveCategoriesToCache(_ categories: [Category]) {
        try? cacheManager.save(object: categories, forKey: categoriesCacheKey)
    }
    
    private func saveSeriesToCache(_ series: [Series]) {
        try? cacheManager.save(object: series, forKey: seriesCacheKey)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        // If we already have data and aren't currently loading, show cached data
        // but refresh in background
        if !seriesList.isEmpty && !categories.isEmpty && !isLoading {
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await self.seriesRepository.loadData()
                }
            }
            return
        }
        
        // Otherwise, load fresh data
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
    
    func createMediaItem(from episode: Episode, seriesName: String) -> MediaItem? {
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
    
    func clearCache() {
        cacheManager.removeAll()
    }
}
