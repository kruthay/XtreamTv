//
//  Networkclient.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// NetworkClient.swift
import Foundation


actor NetworkClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(from url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed(statusCode: 0)
        }
        
        // Check for error status codes
        if httpResponse.statusCode >= 400 {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw NetworkError.decodingFailed(error)
        }
    }
    
    func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.requestFailed(statusCode: 0)
        }
        
        // Check for error status codes
        if httpResponse.statusCode >= 400 {
            throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}
