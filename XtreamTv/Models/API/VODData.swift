//
//  VODData.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//
import Foundation

struct APIVOD: Codable {
    let number: Int
    let name: String
    let streamType: String
    let streamID: String
    let streamIcon: String?
    let added: String
    let categoryID: String
    let containerExtension: String
    
    enum CodingKeys: String, CodingKey {
        case number = "num"
        case name
        case streamType = "stream_type"
        case streamID = "stream_id"
        case streamIcon = "stream_icon"
        case added
        case categoryID = "category_id"
        case containerExtension = "container_extension"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle number as either Int or String
        if let numInt = try? container.decode(Int.self, forKey: .number) {
            self.number = numInt
        } else if let numString = try? container.decode(String.self, forKey: .number),
                  let numInt = Int(numString) {
            self.number = numInt
        } else {
            self.number = 0
        }
        
        name = try container.decode(String.self, forKey: .name)
        streamType = try container.decode(String.self, forKey: .streamType)
        
        // Handle streamID as either Int or String
        if let streamIDInt = try? container.decode(Int.self, forKey: .streamID) {
            self.streamID = String(streamIDInt)
        } else {
            self.streamID = try container.decode(String.self, forKey: .streamID)
        }
        
        streamIcon = try container.decodeIfPresent(String.self, forKey: .streamIcon)
        added = try container.decode(String.self, forKey: .added)
        
        // Handle categoryID as either Int or String
        if let categoryIDInt = try? container.decode(Int.self, forKey: .categoryID) {
            self.categoryID = String(categoryIDInt)
        } else {
            self.categoryID = try container.decode(String.self, forKey: .categoryID)
        }
        
        containerExtension = try container.decode(String.self, forKey: .containerExtension)
    }
}
