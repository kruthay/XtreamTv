//
//  XtreamAPIEndoint.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// XtreamAPIEndpoint.swift
import Foundation

enum XtreamAPIEndpoint {
    case authenticate(username: String, password: String)
    case getLiveStreams(username: String, password: String)
    case getVodStreams(username: String, password: String)
    case getSeries(username: String, password: String)
    case getEPG(streamID: String, username: String, password: String)
    case getLiveStream(streamID: String, username: String, password: String)
    case getVodInfo(vodID: String, username: String, password: String)
    case getSeriesInfo(seriesID: String, username: String, password: String)
    case getLiveCategories(username: String, password: String)
    case getVodCategories(username: String, password: String)
    case getSeriesCategories(username: String, password: String)
    
    func url(baseURL: URL) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        var path = ""
        var queryItems: [URLQueryItem] = []
        
        switch self {
        case .authenticate(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password)
            ]
            
        case .getLiveStreams(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_live_streams")
            ]
            
        case .getVodStreams(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_vod_streams")
            ]
            
        case .getSeries(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_series")
            ]
            
        case .getEPG(let streamID, let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_short_epg"),
                URLQueryItem(name: "stream_id", value: streamID)
            ]
            
        case .getLiveStream(let streamID, let username, let password):
            return baseURL.appendingPathComponent("live")
                .appendingPathComponent(username)
                .appendingPathComponent(password)
                .appendingPathComponent("\(streamID).m3u8")
            
        case .getVodInfo(let vodID, let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_vod_info"),
                URLQueryItem(name: "vod_id", value: vodID)
            ]
            
        case .getSeriesInfo(let seriesID, let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_series_info"),
                URLQueryItem(name: "series_id", value: seriesID)
            ]
            
        case .getLiveCategories(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_live_categories")
            ]
            
        case .getVodCategories(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_vod_categories")
            ]
            
        case .getSeriesCategories(let username, let password):
            path = "/player_api.php"
            queryItems = [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "action", value: "get_series_categories")
            ]
        }
        
        // For special cases already returning a URL
        if path.isEmpty {
            return components.url!
        }
        
        components.path = path
        components.queryItems = queryItems
        return components.url!
    }
}
