//
//  AuthManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// AuthManager.swift
import Foundation
import Combine

class AuthManager: ObservableObject {
    // Published properties for authentication state
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isAuthenticating = false
    @Published private(set) var authError: Error?
    
    // Authentication data
    private(set) var authData: AuthData?
    
    // Credentials
    private(set) var serverURL: URL?
    private(set) var username: String = ""
    private(set) var password: String = ""
    
    // Dependencies
    private let networkClient: NetworkClient
    private let keychainManager: KeychainManaging
    private let userDefaults: UserDefaults
    
    init(
        networkClient: NetworkClient = NetworkClient(),
        keychainManager: KeychainManaging = KeychainManager.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.networkClient = networkClient
        self.keychainManager = keychainManager
        self.userDefaults = userDefaults
        
        // Try to load saved credentials on init
        loadSavedCredentials()
    }
    
    // Load saved credentials from secure storage
    private func loadSavedCredentials() {
        if let savedData = keychainManager.load(key: "xtreamCredentials"),
           let savedString = String(data: savedData, encoding: .utf8) {
            let parts = savedString.components(separatedBy: ":")
            if parts.count == 2 {
                let savedUsername = parts[0]
                let savedPassword = parts[1]
                
                if let serverURLString = userDefaults.string(forKey: "serverURL"),
                   let url = URL(string: serverURLString), !serverURLString.isEmpty {
                    self.serverURL = url
                    self.username = savedUsername
                    self.password = savedPassword
                    self.isAuthenticated = true
                }
            }
        }
    }
    
    // Try to authenticate with saved credentials
    func authenticateWithSavedCredentials() async throws {
        guard let serverURL = serverURL, !username.isEmpty, !password.isEmpty else {
            throw NetworkError.authenticationRequired
        }
        
        return try await authenticate(serverURL: serverURL, username: username, password: password)
    }
    
    // Authenticate with provided credentials
    func authenticate(serverURL: URL, username: String, password: String) async throws {
        // Update state
        await MainActor.run {
            self.isAuthenticating = true
            self.authError = nil
        }
        
        do {
            // Create auth endpoint
            let endpoint = XtreamAPIEndpoint.authenticate(username: username, password: password)
            let url = endpoint.url(baseURL: serverURL)
            
            // Make network request
            let authData: AuthData = try await networkClient.fetch(from: url)
            
            // Check user status
            if authData.userInfo.status != "Active" {
                throw NetworkError.serverError("Account is not active")
            }
            
            // Update state on success
            await MainActor.run {
                self.authData = authData
                self.serverURL = serverURL
                self.username = username
                self.password = password
                self.isAuthenticated = true
                self.isAuthenticating = false
                
                // Save credentials securely
                self.saveCredentials(serverURL: serverURL, username: username, password: password)
            }
        } catch {
            // Update state on failure
            await MainActor.run {
                self.isAuthenticating = false
                self.authError = error
                self.isAuthenticated = false
            }
            throw error
        }
    }
    
    // Save credentials to secure storage
    private func saveCredentials(serverURL: URL, username: String, password: String) {
        // Save to Keychain
        let credentials = "\(username):\(password)"
        if let data = credentials.data(using: .utf8) {
            _ = keychainManager.save(key: "xtreamCredentials", data: data)
        }
        
        // Save server URL to UserDefaults
        userDefaults.set(serverURL.absoluteString, forKey: "serverURL")
    }
    
    // Log out and clear credentials
    func logout() {
        keychainManager.remove(key: "xtreamCredentials")
        userDefaults.removeObject(forKey: "serverURL")
        
        // Reset state
        authData = nil
        serverURL = nil
        username = ""
        password = ""
        isAuthenticated = false
    }
    
    // Get auth parameters for API calls
    var authParams: (serverURL: URL, username: String, password: String)? {
        guard let serverURL = serverURL, isAuthenticated else {
            return nil
        }
        return (serverURL, username, password)
    }
}
