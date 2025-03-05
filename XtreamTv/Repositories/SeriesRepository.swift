//
//  SeriesRepository.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class SeriesRepository: ObservableObject {
    // Published state
    @Published private(set) var series: [Series] = []
    @Published private(set) var categories: [Category] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Cache for series details
    private var seriesInfoCache: [String: SeriesInfo] = [:]
    
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
            let apiCategories = try await service.getSeriesCategories()
            let domainCategories = apiCategories.map { apiCat in
                Category(id: apiCat.categoryID, name: apiCat.categoryName, type: .series)
            }
            
            // Load series
            let apiSeries = try await service.getSeries()
            let domainSeries = apiSeries.map { Series(from: $0) }
            
            await MainActor.run {
                self.categories = domainCategories
                self.series = domainSeries
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
    
    func seriesForCategory(_ categoryID: String) -> [Series] {
        return series.filter { $0.categoryID == categoryID }
    }
    
    func getSeries(byID id: String) -> Series? {
        return series.first { $0.id == id }
    }
    
    func searchSeries(query: String) -> [Series] {
        guard !query.isEmpty else { return [] }
        let lowercasedQuery = query.lowercased()
        return series.filter { $0.name.lowercased().contains(lowercasedQuery) }
    }
    
    func getCategoryName(for categoryID: String) -> String {
        return categories.first { $0.id == categoryID }?.name ?? "Unknown Category"
    }
    
    // MARK: - Series Details
    
    func getSeriesInfo(seriesID: String) async throws -> SeriesInfo {
        // Check cache first
        if let cachedInfo = seriesInfoCache[seriesID] {
            return cachedInfo
        }
        
        // Load from API if not in cache
        let info = try await service.getSeriesInfo(seriesID: seriesID)
        
        // Cache the result
        seriesInfoCache[seriesID] = info
        
        return info
    }
    
    func clearSeriesInfoCache() {
        seriesInfoCache.removeAll()
    }
}
