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
    private let cacheManager: DiskCacheManager
    
    // Cache keys
    private let moviesCacheKey = "cached_movies"
    private let categoriesCacheKey = "cached_categories"
    
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
        
        // Initialize cache manager
        self.cacheManager = DiskCacheManager(
            cacheName: "MoviesViewModelCache",
            expirationInterval: 24 * 60 * 60 // 1 day cache
        )
        
        // Attempt to load from cache first
        loadFromCache()
        
        // Observe repository state
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to repository state and save to cache when updated
        moviesRepository.$movies
            .sink { [weak self] movies in
                self?.movies = movies
                self?.saveMoviesToCache(movies)
            }
            .store(in: &cancellables)
        
        moviesRepository.$categories
            .sink { [weak self] categories in
                self?.categories = categories
                self?.saveCategoriesToCache(categories)
            }
            .store(in: &cancellables)
        
        moviesRepository.$isLoading
            .assign(to: &$isLoading)
        
        moviesRepository.$error
            .assign(to: &$error)
    }
    
    // MARK: - Cache Methods
    
    private func loadFromCache() {
        // Load categories from cache
        if let cachedCategories: [Category] = try? cacheManager.load(forKey: categoriesCacheKey) {
            self.categories = cachedCategories
        }
        
        // Load movies from cache
        if let cachedMovies: [Movie] = try? cacheManager.load(forKey: moviesCacheKey) {
            self.movies = cachedMovies
        }
    }
    
    private func saveCategoriesToCache(_ categories: [Category]) {
        try? cacheManager.save(object: categories, forKey: categoriesCacheKey)
    }
    
    private func saveMoviesToCache(_ movies: [Movie]) {
        try? cacheManager.save(object: movies, forKey: moviesCacheKey)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        // If we already have data and aren't currently loading, use what we have
        if !movies.isEmpty && !categories.isEmpty && !isLoading {
            // Still refresh in background after a short delay
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await self.moviesRepository.loadData()
                }
            }
            return
        }
        
        // Otherwise, load fresh data
        await moviesRepository.loadData()
    }
    
    func refreshData() async {
        // Force a refresh from network
        await moviesRepository.loadData()
    }
    
    func getMoviesForCategory(_ categoryID: String?) -> [Movie] {
        if let categoryID = categoryID {
            return movies.filter { $0.categoryID == categoryID }
        } else {
            return movies
        }
    }
    
    func getMovie(by id: String) -> Movie? {
        return movies.first { $0.id == id }
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return categories.first { $0.id == categoryID }?.name ?? "Unknown"
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
    
    func getCategoriesSortedByName() -> [Category] {
        return categories.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }
    
    func clearCache() {
        cacheManager.removeAll()
    }
}
