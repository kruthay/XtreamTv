//
//  SeriesData.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation

struct APISeries: Codable {
    let name: String
    let seriesID: String
    var cover: String?
    let plot: String?
    let cast: String?
    let director: String?
    let genre: String?
    let releaseDate: String?
    let lastModified: String?
    let rating: String?
    let categoryID: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case seriesID = "series_id"
        case cover
        case plot
        case cast
        case director
        case genre
        case releaseDate = "releaseDate"
        case lastModified = "last_modified"
        case rating
        case categoryID = "category_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle name with fallback for empty strings
        if let nameValue = try? container.decode(String.self, forKey: .name), !nameValue.isEmpty {
            self.name = nameValue
        } else {
            self.name = "Unknown Series"
        }
        
        // Handle seriesID as either Int or String with error handling
        do {
            if let seriesIDInt = try? container.decode(Int.self, forKey: .seriesID) {
                self.seriesID = String(seriesIDInt)
            } else if let seriesIDString = try? container.decode(String.self, forKey: .seriesID), !seriesIDString.isEmpty {
                self.seriesID = seriesIDString
            } else {
                throw DecodingError.valueNotFound(String.self,
                    DecodingError.Context(codingPath: [CodingKeys.seriesID],
                    debugDescription: "Series ID is missing or invalid"))
            }
        } catch {
            // Fallback to random ID if missing
            self.seriesID = UUID().uuidString
        }
        
        // Safely decode optional string values with empty string fallbacks
        if let coverValue = try? container.decodeIfPresent(String.self, forKey: .cover), !coverValue.isEmpty {
            self.cover = coverValue
        } else {
            self.cover = nil
        }
        
        if let plotValue = try? container.decodeIfPresent(String.self, forKey: .plot), !plotValue.isEmpty {
            self.plot = plotValue
        } else {
            self.plot = nil
        }
        
        if let castValue = try? container.decodeIfPresent(String.self, forKey: .cast), !castValue.isEmpty {
            self.cast = castValue
        } else {
            self.cast = nil
        }
        
        if let directorValue = try? container.decodeIfPresent(String.self, forKey: .director), !directorValue.isEmpty {
            self.director = directorValue
        } else {
            self.director = nil
        }
        
        if let genreValue = try? container.decodeIfPresent(String.self, forKey: .genre), !genreValue.isEmpty {
            self.genre = genreValue
        } else {
            self.genre = nil
        }
        
        if let releaseDateValue = try? container.decodeIfPresent(String.self, forKey: .releaseDate), !releaseDateValue.isEmpty {
            self.releaseDate = releaseDateValue
        } else {
            self.releaseDate = nil
        }
        
        if let lastModifiedValue = try? container.decodeIfPresent(String.self, forKey: .lastModified), !lastModifiedValue.isEmpty {
            self.lastModified = lastModifiedValue
        } else {
            self.lastModified = nil
        }
        
        if let ratingValue = try? container.decodeIfPresent(String.self, forKey: .rating), !ratingValue.isEmpty {
            self.rating = ratingValue
        } else {
            self.rating = nil
        }
        
        // Handle categoryID as either Int or String with fallback
        do {
            if let categoryIDInt = try? container.decode(Int.self, forKey: .categoryID) {
                self.categoryID = String(categoryIDInt)
            } else if let categoryIDString = try? container.decode(String.self, forKey: .categoryID), !categoryIDString.isEmpty {
                self.categoryID = categoryIDString
            } else {
                throw DecodingError.valueNotFound(String.self,
                    DecodingError.Context(codingPath: [CodingKeys.categoryID],
                    debugDescription: "Category ID is missing or invalid"))
            }
        } catch {
            // Default to category ID 0 if missing
            self.categoryID = "0"
        }
    }
}


struct Episode: Identifiable, Codable {
    let id: String
    let episodeNum: String
    let title: String
    let containerExtension: String
    let info: EpisodeInfo
    let seasonNum: String
    let seriesID: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case episodeNum = "episode_num"
        case title
        case containerExtension = "container_extension"
        case info
        case seasonNum = "season"
        case seriesID = "series_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Safety handling for ID
        if let idValue = try? container.decode(String.self, forKey: .id), !idValue.isEmpty {
            self.id = idValue
        } else {
            self.id = UUID().uuidString
        }
        
        // Decode episode number safely
        if let episodeNumInt = try? container.decode(Int.self, forKey: .episodeNum) {
            self.episodeNum = String(episodeNumInt)
        } else if let episodeNumString = try? container.decode(String.self, forKey: .episodeNum), !episodeNumString.isEmpty {
            self.episodeNum = episodeNumString
        } else {
            self.episodeNum = "0"
        }
        
        // Decode title with fallback
        if let titleValue = try? container.decode(String.self, forKey: .title), !titleValue.isEmpty {
            self.title = titleValue
        } else {
            self.title = "Episode \(self.episodeNum)"
        }
        
        // Decode container extension with fallback
        if let containerValue = try? container.decode(String.self, forKey: .containerExtension), !containerValue.isEmpty {
            self.containerExtension = containerValue.lowercased()
        } else {
            self.containerExtension = "mp4"
        }
        
        // Decode episode info
        do {
            self.info = try container.decode(EpisodeInfo.self, forKey: .info)
        } catch {
            // Create minimal info object if decoding fails
            self.info = EpisodeInfo(
                movieImage: nil,
                plot: nil,
                releaseDate: nil,
                duration: nil,
                director: nil,
                cast: nil
            )
        }
        
        // Decode season number with fallback
        if let seasonNumInt = try? container.decode(Int.self, forKey: .seasonNum) {
            self.seasonNum = String(seasonNumInt)
        } else if let seasonNumString = try? container.decode(String.self, forKey: .seasonNum), !seasonNumString.isEmpty {
            self.seasonNum = seasonNumString
        } else {
            self.seasonNum = "1"
        }
        
        // Decode series ID with fallback
        if let seriesIDInt = try? container.decode(Int.self, forKey: .seriesID) {
            self.seriesID = String(seriesIDInt)
        } else if let seriesIDString = try? container.decode(String.self, forKey: .seriesID), !seriesIDString.isEmpty {
            self.seriesID = seriesIDString
        } else {
            self.seriesID = "0"
        }
    }
}

// Episode info model
struct EpisodeInfo: Codable {
    var movieImage: String?
    let plot: String?
    let releaseDate: String?
    let duration: String?
    let director: String?
    let cast: String?
    
    enum CodingKeys: String, CodingKey {
        case movieImage = "movie_image"
        case plot
        case releaseDate = "releasedate"
        case duration
        case director
        case cast
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Safely decode optional string values with empty string checks
        if let imageValue = try? container.decodeIfPresent(String.self, forKey: .movieImage), !imageValue.isEmpty {
            self.movieImage = imageValue
        } else {
            self.movieImage = nil
        }
        
        if let plotValue = try? container.decodeIfPresent(String.self, forKey: .plot), !plotValue.isEmpty {
            self.plot = plotValue
        } else {
            self.plot = nil
        }
        
        if let releaseDateValue = try? container.decodeIfPresent(String.self, forKey: .releaseDate), !releaseDateValue.isEmpty {
            self.releaseDate = releaseDateValue
        } else {
            self.releaseDate = nil
        }
        
        if let durationValue = try? container.decodeIfPresent(String.self, forKey: .duration), !durationValue.isEmpty {
            self.duration = durationValue
        } else {
            self.duration = nil
        }
        
        if let directorValue = try? container.decodeIfPresent(String.self, forKey: .director), !directorValue.isEmpty {
            self.director = directorValue
        } else {
            self.director = nil
        }
        
        if let castValue = try? container.decodeIfPresent(String.self, forKey: .cast), !castValue.isEmpty {
            self.cast = castValue
        } else {
            self.cast = nil
        }
    }
    
    // Constructor for fallback values
    init(movieImage: String?, plot: String?, releaseDate: String?, duration: String?, director: String?, cast: String?) {
        self.movieImage = movieImage
        self.plot = plot
        self.releaseDate = releaseDate
        self.duration = duration
        self.director = director
        self.cast = cast
    }
}

// Series info model
struct SeriesInfo: Codable {
    var info: SeriesInfoDetails
    var episodes: [String: [Episode]] // Dictionary mapping season number to episodes
    
    enum CodingKeys: String, CodingKey {
        case info
        case episodes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode info with fallback handling
        do {
            self.info = try container.decode(SeriesInfoDetails.self, forKey: .info)
        } catch {
            // Create minimal info object if decoding fails
            self.info = SeriesInfoDetails(
                name: "Unknown Series",
                cover: nil,
                plot: nil,
                cast: nil,
                director: nil,
                genre: nil,
                releaseDate: nil,
                lastModified: nil,
                rating: nil,
                backdropPath: nil,
                youtubeTrailer: nil
            )
        }
        
        // Decode episodes with fallback handling
        do {
            self.episodes = try container.decode([String: [Episode]].self, forKey: .episodes)
        } catch {
            self.episodes = [:] // Empty dictionary if episodes can't be decoded
        }
    }
}

// Series info details model
struct SeriesInfoDetails: Codable {
    let name: String
    var cover: String?
    let plot: String?
    let cast: String?
    let director: String?
    let genre: String?
    let releaseDate: String?
    let lastModified: String?
    let rating: String?
    let backdropPath: [String]?
    let youtubeTrailer: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case cover
        case plot
        case cast
        case director
        case genre
        case releaseDate = "releaseDate"
        case lastModified = "last_modified"
        case rating
        case backdropPath = "backdrop_path"
        case youtubeTrailer = "youtube_trailer"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle name with fallback
        if let nameValue = try? container.decode(String.self, forKey: .name), !nameValue.isEmpty {
            self.name = nameValue
        } else {
            self.name = "Unknown Series"
        }
        
        // Safely decode optional values
        if let coverValue = try? container.decodeIfPresent(String.self, forKey: .cover), !coverValue.isEmpty {
            self.cover = coverValue
        } else {
            self.cover = nil
        }
        
        if let plotValue = try? container.decodeIfPresent(String.self, forKey: .plot), !plotValue.isEmpty {
            self.plot = plotValue
        } else {
            self.plot = nil
        }
        
        if let castValue = try? container.decodeIfPresent(String.self, forKey: .cast), !castValue.isEmpty {
            self.cast = castValue
        } else {
            self.cast = nil
        }
        
        if let directorValue = try? container.decodeIfPresent(String.self, forKey: .director), !directorValue.isEmpty {
            self.director = directorValue
        } else {
            self.director = nil
        }
        
        if let genreValue = try? container.decodeIfPresent(String.self, forKey: .genre), !genreValue.isEmpty {
            self.genre = genreValue
        } else {
            self.genre = nil
        }
        
        if let releaseDateValue = try? container.decodeIfPresent(String.self, forKey: .releaseDate), !releaseDateValue.isEmpty {
            self.releaseDate = releaseDateValue
        } else {
            self.releaseDate = nil
        }
        
        if let lastModifiedValue = try? container.decodeIfPresent(String.self, forKey: .lastModified), !lastModifiedValue.isEmpty {
            self.lastModified = lastModifiedValue
        } else {
            self.lastModified = nil
        }
        
        if let ratingValue = try? container.decodeIfPresent(String.self, forKey: .rating), !ratingValue.isEmpty {
            self.rating = ratingValue
        } else {
            self.rating = nil
        }
        
        // Handle backdrop path as either string array or single string
        do {
            if let backdropArray = try? container.decodeIfPresent([String].self, forKey: .backdropPath) {
                self.backdropPath = backdropArray
            } else if let backdropString = try? container.decodeIfPresent(String.self, forKey: .backdropPath), !backdropString.isEmpty {
                self.backdropPath = [backdropString]
            } else {
                self.backdropPath = nil
            }
        }
        
        if let youtubeValue = try? container.decodeIfPresent(String.self, forKey: .youtubeTrailer), !youtubeValue.isEmpty {
            self.youtubeTrailer = youtubeValue
        } else {
            self.youtubeTrailer = nil
        }
    }
    
    // Constructor for fallback values
    init(name: String, cover: String?, plot: String?, cast: String?, director: String?,
         genre: String?, releaseDate: String?, lastModified: String?, rating: String?,
         backdropPath: [String]?, youtubeTrailer: String?) {
        self.name = name
        self.cover = cover
        self.plot = plot
        self.cast = cast
        self.director = director
        self.genre = genre
        self.releaseDate = releaseDate
        self.lastModified = lastModified
        self.rating = rating
        self.backdropPath = backdropPath
        self.youtubeTrailer = youtubeTrailer
    }
}
