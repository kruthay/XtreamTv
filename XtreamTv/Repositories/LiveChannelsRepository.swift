//
//  LiveChannelsRepository.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class LiveChannelsRepository: ObservableObject {
    // Published state
    @Published private(set) var channels: [Channel] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Dependencies
    private let service: XtreamService
    
    init(service: XtreamService) {
        self.service = service
    }
    
    // MARK: - Data Loading
    
    func loadData() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Load categories first
            let apiCategories = try await service.getLiveCategories()
            let domainCategories = apiCategories.map { apiCat in
                Category(id: apiCat.categoryID, name: apiCat.categoryName, type: .live)
            }
            
            // Load channels
            let apiChannels = try await service.getLiveStreams()
            let domainChannels = apiChannels.map { Channel(from: $0) }
            
            await MainActor.run {
                self.categories = domainCategories
                self.channels = domainChannels
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Data Access
    
    func channelsForCategory(_ categoryID: String) -> [Channel] {
        return channels.filter { $0.categoryID == categoryID }
    }
    
    func getChannel(byID id: String) -> Channel? {
        return channels.first { $0.id == id }
    }
    
    func searchChannels(query: String) -> [Channel] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return channels.filter { $0.name.lowercased().contains(lowercasedQuery) }
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return categories.first { $0.id == categoryID }?.name ?? "Unknown Category"
    }
}
