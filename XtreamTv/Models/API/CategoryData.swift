//
//  CategoryData.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

struct ApiCategory: Codable, Identifiable {
    let categoryID: String
    let categoryName: String
    let parentID: Int
    
    var id: String { categoryID }
    
    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case parentID = "parent_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle categoryID as either Int or String
        if let categoryIDInt = try? container.decode(Int.self, forKey: .categoryID) {
            self.categoryID = String(categoryIDInt)
        } else {
            self.categoryID = try container.decode(String.self, forKey: .categoryID)
        }
        
        categoryName = try container.decode(String.self, forKey: .categoryName)
        
        // Handle parentID as either Int or String
        if let parentIDString = try? container.decode(String.self, forKey: .parentID),
           let parentIDInt = Int(parentIDString) {
            self.parentID = parentIDInt
        } else {
            self.parentID = try container.decode(Int.self, forKey: .parentID)
        }
    }
}
