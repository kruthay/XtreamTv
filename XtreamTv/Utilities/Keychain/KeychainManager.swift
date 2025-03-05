//
//  KeychainManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Utilities/KeychainManager.swift
import Foundation
import Security

// Protocol for Keychain operations to enable testing
protocol KeychainManaging {
    func save(key: String, data: Data) -> Bool
    func load(key: String) -> Data?
    func remove(key: String)
}

class KeychainManager: KeychainManaging {
    static let shared = KeychainManager()
    
    private let service: String
    
    // Private initializer for singleton
    private init(service: String = Bundle.main.bundleIdentifier ?? "com.app.iptv") {
        self.service = service
    }
    
    // MARK: - Public Methods
    
    /// Save data to Keychain
    /// - Parameters:
    ///   - key: The key to associate with the data
    ///   - data: The data to store
    /// - Returns: Boolean indicating success
    func save(key: String, data: Data) -> Bool {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Delete any existing value first
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Log result for debugging
        if status != errSecSuccess {
            logError("Failed to save item to Keychain: \(status)")
        }
        
        return status == errSecSuccess
    }
    
    /// Save a string to Keychain
    /// - Parameters:
    ///   - key: The key to associate with the string
    ///   - string: The string to store
    /// - Returns: Boolean indicating success
    func saveString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else {
            return false
        }
        return save(key: key, data: data)
    }
    
    /// Load data from Keychain
    /// - Parameter key: The key associated with the data
    /// - Returns: The data if found, nil otherwise
    func load(key: String) -> Data? {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Perform the query
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check result
        if status != errSecSuccess && status != errSecItemNotFound {
            logError("Failed to load item from Keychain: \(status)")
        }
        
        return result as? Data
    }
    
    /// Load a string from Keychain
    /// - Parameter key: The key associated with the string
    /// - Returns: The string if found, nil otherwise
    func loadString(forKey key: String) -> String? {
        guard let data = load(key: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Remove an item from Keychain
    /// - Parameter key: The key associated with the item to remove
    func remove(key: String) {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        // Perform the delete
        let status = SecItemDelete(query as CFDictionary)
        
        // Check result
        if status != errSecSuccess && status != errSecItemNotFound {
            logError("Failed to remove item from Keychain: \(status)")
        }
    }
    
    /// Remove all items for this app from Keychain
    func removeAll() {
        // Create query dictionary to match all items for this service
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        // Perform the delete
        let status = SecItemDelete(query as CFDictionary)
        
        // Check result
        if status != errSecSuccess && status != errSecItemNotFound {
            logError("Failed to remove all items from Keychain: \(status)")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Checks if a key exists in Keychain
    /// - Parameter key: The key to check
    /// - Returns: Boolean indicating if the key exists
    func hasKey(_ key: String) -> Bool {
        return load(key: key) != nil
    }
    
    /// Update an existing item or create it if it doesn't exist
    /// - Parameters:
    ///   - key: The key to associate with the data
    ///   - data: The data to store
    /// - Returns: Boolean indicating success
    func update(key: String, data: Data) -> Bool {
        if hasKey(key) {
            // Create query dictionary
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key
            ]
            
            // Create update dictionary
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            // Perform the update
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            
            // Log result for debugging
            if status != errSecSuccess {
                logError("Failed to update item in Keychain: \(status)")
            }
            
            return status == errSecSuccess
        } else {
            return save(key: key, data: data)
        }
    }
    
    /// Update an existing string or create it if it doesn't exist
    /// - Parameters:
    ///   - string: The string to store
    ///   - key: The key to associate with the string
    /// - Returns: Boolean indicating success
    func updateString(_ string: String, forKey key: String) -> Bool {
        guard let data = string.data(using: .utf8) else {
            return false
        }
        return update(key: key, data: data)
    }
    
    // MARK: - Private Methods
    
    private func logError(_ message: String) {
        #if DEBUG
        print("KeychainManager Error: \(message)")
        #endif
    }
}

// MARK: - String Extension for Credential Storage
extension KeychainManager {
    /// Save credentials (username and password) to Keychain
    /// - Parameters:
    ///   - username: The username to store
    ///   - password: The password to store
    ///   - key: The key to associate with the credentials
    /// - Returns: Boolean indicating success
    func saveCredentials(username: String, password: String, forKey key: String) -> Bool {
        let credentials = "\(username):\(password)"
        return saveString(credentials, forKey: key)
    }
    
    /// Load credentials (username and password) from Keychain
    /// - Parameter key: The key associated with the credentials
    /// - Returns: Tuple containing username and password if found, nil otherwise
    func loadCredentials(forKey key: String) -> (username: String, password: String)? {
        guard let credentialsString = loadString(forKey: key) else {
            return nil
        }
        
        let components = credentialsString.components(separatedBy: ":")
        guard components.count == 2 else {
            return nil
        }
        
        return (username: components[0], password: components[1])
    }
}
