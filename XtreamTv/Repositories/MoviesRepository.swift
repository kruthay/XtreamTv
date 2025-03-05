//
//  MoviesRepository.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class MoviesRepository: ObservableObject {
    // Published state
    @Published private(set) var movies: [Movie] = []
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
            let apiCategories = try await service.getVODCategories()
            let domainCategories = apiCategories.map { apiCat in
                Category(id: apiCat.categoryID, name: apiCat.categoryName, type: .vod)
            }
            
            // Load movies
            let apiMovies = try await service.getVODStreams()
            let domainMovies = apiMovies.map { Movie(from: $0) }
            
            await MainActor.run {
                self.categories = domainCategories
                self.movies = domainMovies
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
    
    func moviesForCategory(_ categoryID: String) -> [Movie] {
        return movies.filter { $0.categoryID == categoryID }
    }
    
    func getMovie(byID id: String) -> Movie? {
        return movies.first { $0.id == id }
    }
    
    func searchMovies(query: String) -> [Movie] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return movies.filter { $0.name.lowercased().contains(lowercasedQuery) }
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return categories.first { $0.id == categoryID }?.name ?? "Unknown Category"
    }
}
