//
//  MediaItem.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// MediaItem.swift
import Foundation

struct MediaItem: Identifiable, Equatable {
    let id: String
    let title: String
    let streamURL: URL
    let alternativeURLs: [URL]
    let thumbnailURL: URL?
    let contentType: MediaContentType
    let fileExtension: String?
    
    enum MediaContentType {
        case liveTV
        case movie
        case episode
    }
    
    var isLiveStream: Bool {
        return contentType == .liveTV
    }
    
    // Factory methods for creating media items
    static func fromChannel(
        channel: Channel,
        streamProvider: MediaStreamProvider
    ) -> MediaItem? {
        guard let streamURL = streamProvider.getLiveStreamURL(channelID: channel.streamID) else {
            return nil
        }
        
        let alternativeURLs = streamProvider.getAlternativeStreamURLs(
            for: .liveTV,
            id: channel.streamID
        )
        
        return MediaItem(
            id: channel.id,
            title: channel.name,
            streamURL: streamURL,
            alternativeURLs: alternativeURLs,
            thumbnailURL: channel.thumbnailURL,
            contentType: .liveTV,
            fileExtension: "m3u8"
        )
    }
    
    static func fromMovie(
        movie: Movie,
        streamProvider: MediaStreamProvider
    ) -> MediaItem? {
        guard let streamURL = streamProvider.getMovieStreamURL(
            movieID: movie.streamID,
            fileExtension: movie.containerExtension
        ) else {
            return nil
        }
        
        let alternativeURLs = streamProvider.getAlternativeStreamURLs(
            for: .movie,
            id: movie.streamID
        )
        
        return MediaItem(
            id: movie.id,
            title: movie.name,
            streamURL: streamURL,
            alternativeURLs: alternativeURLs,
            thumbnailURL: movie.thumbnailURL,
            contentType: .movie,
            fileExtension: movie.containerExtension
        )
    }
    
    static func fromEpisode(
        episode: Episode,
        seriesName: String,
        streamProvider: MediaStreamProvider
    ) -> MediaItem? {
        guard let streamURL = streamProvider.getEpisodeStreamURL(
            seriesID: episode.seriesID,
            episodeID: episode.id,
            fileExtension: episode.containerExtension
        ) else {
            return nil
        }
        
        let alternativeURLs = streamProvider.getAlternativeStreamURLs(
            for: .episode,
            id: episode.id
        )
        
        let fullTitle = "\(seriesName) - S\(episode.seasonNum)E\(episode.episodeNum) - \(episode.title)"
        
        return MediaItem(
            id: episode.id,
            title: fullTitle,
            streamURL: streamURL,
            alternativeURLs: alternativeURLs,
            thumbnailURL: episode.info.movieImage != nil ? URL(string: episode.info.movieImage!) : nil,
            contentType: .episode,
            fileExtension: episode.containerExtension
        )
    }
}
