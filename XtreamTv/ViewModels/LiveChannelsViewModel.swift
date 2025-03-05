//
//  LiveChannelsViewModel.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

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
        
        // Observe repository state
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to repository state
        channelsRepository.$channels
            .assign(to: &$channels)
        
        channelsRepository.$categories
            .assign(to: &$categories)
        
        channelsRepository.$isLoading
            .assign(to: &$isLoading)
        
        channelsRepository.$error
            .assign(to: &$error)
    }
    
    // MARK: - Public Methods
    
    func loadData() async {
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
}

