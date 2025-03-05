//
//  ErrorHandling.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Utilities/ErrorHandling.swift
import Foundation

// Base protocol for app errors
protocol AppError: Error, LocalizedError {
    var errorCode: Int { get }
    var errorCategory: ErrorCategory { get }
    var isRecoverable: Bool { get }
    var recoveryAction: (() -> Void)? { get }
}

// Error categories
enum ErrorCategory {
    case network
    case authentication
    case dataFormat
    case playback
    case storage
    case general
}

// Default implementation for AppError
extension AppError {
    // Default is recoverable = false with no recovery action
    var isRecoverable: Bool { return false }
    var recoveryAction: (() -> Void)? { return nil }
}

// Network Errors
enum NetworkError: AppError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case noData
    case decodingFailed(Error)
    case authenticationRequired
    case serverError(String)
    case connectionFailed
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL format"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .noData:
            return "No data received from server"
        case .decodingFailed:
            return "Could not process the data from server"
        case .authenticationRequired:
            return "Authentication required. Please log in again."
        case .serverError(let message):
            return "Server error: \(message)"
        case .connectionFailed:
            return "Could not connect to the server. Please check your internet connection."
        case .timeout:
            return "The request timed out. Please try again."
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidURL: return 1001
        case .requestFailed(let statusCode): return statusCode
        case .noData: return 1003
        case .decodingFailed: return 1004
        case .authenticationRequired: return 1005
        case .serverError: return 1006
        case .connectionFailed: return 1007
        case .timeout: return 1008
        }
    }
    
    var errorCategory: ErrorCategory {
        return .network
    }
    
    var isRecoverable: Bool {
        switch self {
        case .authenticationRequired, .connectionFailed, .timeout:
            return true
        default:
            return false
        }
    }
}

// Authentication Errors
enum AuthError: AppError {
    case invalidCredentials
    case sessionExpired
    case notAuthenticated
    case credentialStorageFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .sessionExpired:
            return "Your session has expired. Please log in again."
        case .notAuthenticated:
            return "You need to log in to access this feature"
        case .credentialStorageFailed:
            return "Failed to securely store your credentials"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidCredentials: return 2001
        case .sessionExpired: return 2002
        case .notAuthenticated: return 2003
        case .credentialStorageFailed: return 2004
        }
    }
    
    var errorCategory: ErrorCategory {
        return .authentication
    }
    
    var isRecoverable: Bool {
        switch self {
        case .sessionExpired, .notAuthenticated:
            return true
        default:
            return false
        }
    }
}

// Playback Errors
enum PlaybackError: AppError {
    case unsupportedFormat
    case accessDenied
    case streamUnavailable
    case externalPlayerRequired
    case playerInitFailed
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "This media format is not supported"
        case .accessDenied:
            return "You don't have permission to view this content"
        case .streamUnavailable:
            return "This stream is currently unavailable"
        case .externalPlayerRequired:
            return "This file requires an external player"
        case .playerInitFailed:
            return "Failed to initialize the media player"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .unsupportedFormat: return 3001
        case .accessDenied: return 3002
        case .streamUnavailable: return 3003
        case .externalPlayerRequired: return 3004
        case .playerInitFailed: return 3005
        }
    }
    
    var errorCategory: ErrorCategory {
        return .playback
    }
    
    var isRecoverable: Bool {
        switch self {
        case .externalPlayerRequired:
            return true
        default:
            return false
        }
    }
}

// Global error handler
class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handle(_ error: Error, source: AnyObject? = nil) {
        // Log the error
        logError(error, category: .general)
        
        // Convert to AppError if possible for better handling
        let appError: AppError
        if let err = error as? AppError {
            appError = err
        } else {
            // Wrap system errors
            appError = GeneralError.systemError(error)
        }
        
        // Handle based on category
        switch appError.errorCategory {
        case .network:
            handleNetworkError(appError)
        case .authentication:
            handleAuthError(appError)
        case .playback:
            handlePlaybackError(appError)
        default:
            // Default handling
            break
        }
        
        // Analytics tracking (could be implemented)
        trackError(appError)
    }
    
    private func handleNetworkError(_ error: AppError) {
        // Network-specific handling like retries, connectivity checks
    }
    
    private func handleAuthError(_ error: AppError) {
        // Auth-specific handling like re-login prompts
    }
    
    private func handlePlaybackError(_ error: AppError) {
        // Playback-specific handling like trying alternative formats
    }
    
    private func trackError(_ error: AppError) {
        // Send to analytics service
        // This would connect to your analytics system
    }
}

// General errors
enum GeneralError: AppError {
    case systemError(Error)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .systemError(let error):
            return "System error: \(error.localizedDescription)"
        case .unknown(let message):
            return message.isEmpty ? "An unknown error occurred" : message
        }
    }
    
    var errorCode: Int {
        switch self {
        case .systemError: return 9001
        case .unknown: return 9999
        }
    }
    
    var errorCategory: ErrorCategory {
        return .general
    }
}
