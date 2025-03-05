import Foundation
import Combine

class LiveChannelsViewModel: ObservableObject {
    // Published state
    @Published private(set) var channels: [Channel] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Dependencies
    private let channelsRepository: LiveChannelsRepository
    private let userPreferences: UserPreferencesManager
    private let mediaStreamProvider: MediaStreamProvider
    
    // Cache
    private let cacheManager: DiskCacheManager
    private let categoriesCacheKey = "cached_live_categories"
    private let channelsCacheKey   = "cached_live_channels"
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(
        channelsRepository: LiveChannelsRepository,
        userPreferences: UserPreferencesManager,
        mediaStreamProvider: MediaStreamProvider
    ) {
        self.channelsRepository = channelsRepository
        self.userPreferences = userPreferences
        self.mediaStreamProvider = mediaStreamProvider
        
        // Initialize a disk cache manager (1-day expiration or whatever you prefer)
        self.cacheManager = DiskCacheManager(
            cacheName: "LiveChannelsViewModelCache",
            expirationInterval: 24 * 60 * 60
        )
        
        // Attempt to load from cache
        loadFromCache()
        
        // Observe repository state
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to repository state and update local Published properties
        channelsRepository.$channels
            .sink { [weak self] channels in
                self?.channels = channels
                self?.saveChannelsToCache(channels)
            }
            .store(in: &cancellables)
        
        channelsRepository.$categories
            .sink { [weak self] categories in
                self?.categories = categories
                self?.saveCategoriesToCache(categories)
            }
            .store(in: &cancellables)
        
        channelsRepository.$isLoading
            .assign(to: &$isLoading)
        
        channelsRepository.$error
            .assign(to: &$error)
    }
    
    // MARK: - Cache Methods
    
    private func loadFromCache() {
        // Load cached categories
        if let cachedCategories: [Category] = try? cacheManager.load(forKey: categoriesCacheKey) {
            self.categories = cachedCategories
        }
        
        // Load cached channels
        if let cachedChannels: [Channel] = try? cacheManager.load(forKey: channelsCacheKey) {
            self.channels = cachedChannels
        }
    }
    
    private func saveCategoriesToCache(_ categories: [Category]) {
        try? cacheManager.save(object: categories, forKey: categoriesCacheKey)
    }
    
    private func saveChannelsToCache(_ channels: [Channel]) {
        try? cacheManager.save(object: channels, forKey: channelsCacheKey)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
        // If we already have data and aren't currently loading, use what we have
        if !channels.isEmpty && !categories.isEmpty && !isLoading {
            // Still refresh from network in background
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                Task {
                    await self.channelsRepository.loadData()
                }
            }
            return
        }
        
        // Otherwise, load fresh data
        await channelsRepository.loadData()
    }
    
    func getChannelsForCategory(_ categoryID: String?) -> [Channel] {
        if let categoryID = categoryID {
            return channelsRepository.channelsForCategory(categoryID)
        } else {
            return channels
        }
    }
    
    func getChannel(by id: String) -> Channel? {
        return channelsRepository.getChannel(byID: id)
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return channelsRepository.getCategoryName(for: categoryID)
    }
    
    func createMediaItem(from channel: Channel) -> MediaItem? {
        return MediaItem.fromChannel(
            channel: channel,
            streamProvider: mediaStreamProvider
        )
    }
    
    func isFavorite(channelID: String) -> Bool {
        return userPreferences.isFavorite(contentID: channelID)
    }
    
    func toggleFavorite(channelID: String) {
        userPreferences.toggleFavorite(contentID: channelID)
    }
    
    func addToRecentlyWatched(channelID: String) {
        userPreferences.addToRecentlyWatched(contentID: channelID)
    }
    
    func clearCache() {
        cacheManager.removeAll()
    }
}
