//
//  SearchViewModel.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    // Published state
    @Published var searchText = "" {
        didSet {
            if !searchText.isEmpty {
                performSearch()
            } else {
                clearResults()
            }
        }
    }
    
    @Published private(set) var channelResults: [Channel] = []
    @Published private(set) var movieResults: [Movie] = []
    @Published private(set) var seriesResults: [Series] = []
    @Published private(set) var isSearching = false
    @Published private(set) var error: Error?
    
    // Dependencies
    private let contentManager: ContentManager
    
    // Debounce search
    private var searchTask: Task<Void, Never>?
    
    init(contentManager: ContentManager) {
        self.contentManager = contentManager
    }
    
    // MARK: - Search Methods
    
    private func performSearch() {
        // Cancel previous search
        searchTask?.cancel()
        
        // Debounce search input
        searchTask = Task {
            // Wait a short time to avoid searching on every keystroke
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                isSearching = true
            }
            
            let results = await search(query: searchText)
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.channelResults = results.channels
                self.movieResults = results.movies
                self.seriesResults = results.series
                self.isSearching = false
            }
        }
    }
    
    private func search(query: String) async -> (channels: [Channel], movies: [Movie], series: [Series]) {
        return await withCheckedContinuation { continuation in
            let results = contentManager.search(query: query)
            continuation.resume(returning: results)
        }
    }
    
    private func clearResults() {
        channelResults = []
        movieResults = []
        seriesResults = []
    }
    
    // MARK: - Helper Methods
    
    func hasResults() -> Bool {
        return !channelResults.isEmpty || !movieResults.isEmpty || !seriesResults.isEmpty
    }
}
