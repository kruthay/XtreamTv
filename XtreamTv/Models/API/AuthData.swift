//
//  AuthData.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

struct AuthData: Codable {
    let userInfo: UserInfo
    let serverInfo: ServerInfo
    
    enum CodingKeys: String, CodingKey {
        case userInfo = "user_info"
        case serverInfo = "server_info"
    }
}
struct UserInfo: Codable {
    let username: String
    let status: String
    let expDate: String
    let maxConnections: String
    
    enum CodingKeys: String, CodingKey {
        case username
        case status
        case expDate = "exp_date"
        case maxConnections = "max_connections"
    }
}

struct ServerInfo: Codable {
    let url: String
    let port: String
    let httpsPort: String
    
    enum CodingKeys: String, CodingKey {
        case url
        case port
        case httpsPort = "https_port"
    }
}
