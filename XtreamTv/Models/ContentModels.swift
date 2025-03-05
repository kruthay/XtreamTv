//
//  ContentModels.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Models/ContentModels.swift
import Foundation

// Base content type for all media types
protocol ContentItem: Identifiable {
    var id: String { get }
    var name: String { get }
    var categoryID: String { get }
    var thumbnailURL: URL? { get }
}

// Live TV channel model
struct Channel: ContentItem, Equatable, Codable {
    let id: String
    let name: String
    let streamID: String
    let categoryID: String
    let thumbnailURL: URL?
    let epgChannelID: String?
    let number: Int
    let streamType: String
    let tvArchive: Bool
    
    init(from apiChannel: APIChannel) {
        self.id = apiChannel.streamID
        self.name = apiChannel.name
        self.streamID = apiChannel.streamID
        self.categoryID = apiChannel.categoryID
        self.thumbnailURL = apiChannel.streamIcon != nil ? URL(string: apiChannel.streamIcon!) : nil
        self.epgChannelID = apiChannel.epgChannelID
        self.number = apiChannel.number
        self.streamType = apiChannel.streamType
        self.tvArchive = apiChannel.tvArchive > 0
    }
}

// VOD movie model
struct Movie: ContentItem, Equatable, Codable {
    let id: String
    let name: String
    let streamID: String
    let categoryID: String
    let thumbnailURL: URL?
    let containerExtension: String
    let addedDate: Date?
    
    init(from apiVOD: APIVOD) {
        self.id = apiVOD.streamID
        self.name = apiVOD.name
        self.streamID = apiVOD.streamID
        self.categoryID = apiVOD.categoryID
        self.thumbnailURL = apiVOD.streamIcon != nil ? URL(string: apiVOD.streamIcon!) : nil
        self.containerExtension = apiVOD.containerExtension
        
        // Parse added date if possible
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.addedDate = dateFormatter.date(from: apiVOD.added)
    }
}

// TV Series model
struct Series: ContentItem, Equatable, Codable {
    let id: String
    let name: String
    let seriesID: String
    let categoryID: String
    let thumbnailURL: URL?
    let plot: String?
    let genre: String?
    let releaseDate: String?
    let rating: String?
    
    init(from apiSeries: APISeries) {
        self.id = apiSeries.seriesID
        self.name = apiSeries.name
        self.seriesID = apiSeries.seriesID
        self.categoryID = apiSeries.categoryID
        self.thumbnailURL = apiSeries.cover != nil ? URL(string: apiSeries.cover!) : nil
        self.plot = apiSeries.plot
        self.genre = apiSeries.genre
        self.releaseDate = apiSeries.releaseDate
        self.rating = apiSeries.rating
    }
}

// Content category model
struct Category: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let type: CategoryType
}

enum CategoryType: String, Codable {
    case live
    case vod
    case series
}
