//
//  MediaStreamProvider.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// MediaStreamProvider.swift
import Foundation

protocol MediaStreamProvider {
    func getLiveStreamURL(channelID: String) -> URL?
    func getMovieStreamURL(movieID: String, fileExtension: String?) -> URL?
    func getEpisodeStreamURL(seriesID: String, episodeID: String, fileExtension: String?) -> URL?
    func getAlternativeStreamURLs(for itemType: MediaItemType, id: String) -> [URL]
}

enum MediaItemType {
    case liveTV
    case movie
    case episode
}

class XtreamMediaStreamProvider: MediaStreamProvider {
    private let authManager: AuthManager
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func getLiveStreamURL(channelID: String) -> URL? {
        guard let params = authManager.authParams else { return nil }
        
        return params.serverURL
            .appendingPathComponent("live")
            .appendingPathComponent(params.username)
            .appendingPathComponent(params.password)
            .appendingPathComponent("\(channelID).m3u8")
    }
    
    func getMovieStreamURL(movieID: String, fileExtension: String? = nil) -> URL? {
        guard let params = authManager.authParams else { return nil }
        
        let ext = fileExtension ?? "mp4"
        
        return params.serverURL
            .appendingPathComponent("movie")
            .appendingPathComponent(params.username)
            .appendingPathComponent(params.password)
            .appendingPathComponent("\(movieID).\(ext)")
    }
    
    func getEpisodeStreamURL(seriesID: String, episodeID: String, fileExtension: String? = nil) -> URL? {
        guard let params = authManager.authParams else { return nil }
        
        let ext = fileExtension ?? "mp4"
        
        return params.serverURL
            .appendingPathComponent("series")
            .appendingPathComponent(params.username)
            .appendingPathComponent(params.password)
            .appendingPathComponent("\(episodeID).\(ext)")
    }
    
    func getAlternativeStreamURLs(for itemType: MediaItemType, id: String) -> [URL] {
        var urls: [URL] = []
        
        switch itemType {
        case .liveTV:
            if let url1 = getLiveStreamURL(channelID: id) {
                urls.append(url1)
            }
            
            // Add TS format alternative
            if let params = authManager.authParams {
                let tsURL = params.serverURL
                    .appendingPathComponent("live")
                    .appendingPathComponent(params.username)
                    .appendingPathComponent(params.password)
                    .appendingPathComponent("\(id).ts")
                urls.append(tsURL)
                
                // Add direct format alternative
                let directURL = params.serverURL
                    .appendingPathComponent("live")
                    .appendingPathComponent(params.username)
                    .appendingPathComponent(params.password)
                    .appendingPathComponent(id)
                urls.append(directURL)
            }
            
        case .movie:
            // Try different extensions
            for ext in ["mp4", "mkv", "m3u8", "ts"] {
                if let url = getMovieStreamURL(movieID: id, fileExtension: ext) {
                    urls.append(url)
                }
            }
            
        case .episode:
            // Try different extensions
            for ext in ["mp4", "mkv", "m3u8", "ts"] {
                if let url = getEpisodeStreamURL(seriesID: "", episodeID: id, fileExtension: ext) {
                    urls.append(url)
                }
            }
        }
        
        return urls
    }
}
