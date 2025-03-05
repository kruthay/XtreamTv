//
//  AuthViewModel.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import Foundation
import Combine

class AuthViewModel: ObservableObject {
    // Published state
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isAuthenticating = false
    @Published private(set) var error: Error?
    
    // Form fields
    @Published var serverURL = ""
    @Published var username = ""
    @Published var password = ""
    
    // Dependencies
    private let authManager: AuthManager
    private let contentManager: ContentManager
    
    // Validation
    var isFormValid: Bool {
        return !serverURL.isEmpty && !username.isEmpty && !password.isEmpty
    }
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManager, contentManager: ContentManager) {
        self.authManager = authManager
        self.contentManager = contentManager
        
        // Bind to auth manager state
        setupBindings()
    }
    
    private func setupBindings() {
        authManager.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authManager.$isAuthenticating
            .assign(to: &$isAuthenticating)
        
        authManager.$authError
            .assign(to: &$error)
    }
    
    // MARK: - Authentication Methods
    
    func login() async {
        guard isFormValid else {
            await MainActor.run {
                self.error = NSError(
                    domain: "AuthViewModel",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Please fill all fields"]
                )
            }
            return
        }
        
        guard let url = URL(string: serverURL) else {
            await MainActor.run {
                self.error = NSError(
                    domain: "AuthViewModel",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid server URL"]
                )
            }
            return
        }
        
        do {
            try await authManager.authenticate(
                serverURL: url,
                username: username,
                password: password
            )
            
            // Load content after successful login
            if isAuthenticated {
                await contentManager.loadAllData()
            }
        } catch {
            // Error is already handled by the auth manager
            print("Login failed: \(error)")
        }
    }
    
    func logout() {
        authManager.logout()
    }
    
    func tryAutoLogin() async {
        if authManager.isAuthenticated {
            await contentManager.loadAllData()
        }
    }
}
