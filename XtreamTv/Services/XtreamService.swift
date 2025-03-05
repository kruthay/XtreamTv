//
//  XtreamService.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// XtreamService.swift
import Foundation
import AVFoundation
import Combine

class XtreamService: ObservableObject {
    // Dependencies
    private let networkClient: NetworkClient
    private let authManager: AuthManager
    
    // Published state
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init(networkClient: NetworkClient = NetworkClient(), authManager: AuthManager = AuthManager()) {
        self.networkClient = networkClient
        self.authManager = authManager
    }
    
    // MARK: - API Methods
    
    func getLiveCategories() async throws -> [ApiCategory] {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getLiveCategories(
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    func getVODCategories() async throws -> [ApiCategory] {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getVodCategories(
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    func getSeriesCategories() async throws -> [ApiCategory] {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getSeriesCategories(
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    func getLiveStreams() async throws -> [APIChannel] {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getLiveStreams(
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    
    func getVODStreams() async throws -> [APIVOD] {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getVodStreams(
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    
    func getSeries() async throws -> [APISeries] {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getSeries(
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    func getSeriesInfo(seriesID: String) async throws -> SeriesInfo {
        try await executeAuthenticatedRequest { params in
            let endpoint = XtreamAPIEndpoint.getSeriesInfo(
                seriesID: seriesID,
                username: params.username,
                password: params.password
            )
            
            return try await self.networkClient.fetch(from: endpoint.url(baseURL: params.serverURL))
        }
    }
    
    // Helper method to get stream URLs
    func getLiveStreamURL(streamID: String) -> URL? {
        guard let params = authManager.authParams else { return nil }
        
        let endpoint = XtreamAPIEndpoint.getLiveStream(
            streamID: streamID,
            username: params.username,
            password: params.password
        )
        
        return endpoint.url(baseURL: params.serverURL)
    }
    
    func getVODStreamURL(vodID: String, extension: String = "mp4") -> URL? {
        guard let params = authManager.authParams else { return nil }
        
        return params.serverURL
            .appendingPathComponent("movie")
            .appendingPathComponent(params.username)
            .appendingPathComponent(params.password)
            .appendingPathComponent("\(vodID).\(`extension`)")
    }
    
    func getSeriesStreamURL(seriesID: String, episodeID: String) -> URL? {
        guard let params = authManager.authParams else { return nil }
        
        return params.serverURL
            .appendingPathComponent("series")
            .appendingPathComponent(params.username)
            .appendingPathComponent(params.password)
            .appendingPathComponent("\(episodeID).mp4")
    }
    
    // MARK: - Helper Methods
    
    private func executeAuthenticatedRequest<T>(
        _ request: @escaping ((serverURL: URL, username: String, password: String)) async throws -> T
    ) async throws -> T {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Check if we're authenticated
            if !authManager.isAuthenticated {
                try await authManager.authenticateWithSavedCredentials()
            }
            
            // Get auth parameters
            guard let params = authManager.authParams else {
                throw NetworkError.authenticationRequired
            }
            
            // Execute the request with auth parameters
            let result = try await request(params)
            
            await MainActor.run {
                self.isLoading = false
            }
            
            return result
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.error = error
            }
            throw error
        }
    }
}
