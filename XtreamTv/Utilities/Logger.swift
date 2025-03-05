//
//  Logger.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Utilities/Logger.swift
import Foundation
import os.log

enum LogLevel: Int {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .default
        case .error: return .error
        }
    }
    
    var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

class Logger {
    // Singleton instance
    static let shared = Logger()
    
    // OS Logger categories
    private let networkLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.iptv", category: "Network")
    private let uiLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.iptv", category: "UI")
    private let playbackLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.iptv", category: "Playback")
    private let cacheLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.iptv", category: "Cache")
    private let generalLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.app.iptv", category: "General")
    
    // Minimum log level (configurable)
    private var minimumLogLevel: LogLevel = {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }()
    
    // In-memory logs for debugging
    private var inMemoryLogs: [String] = []
    private let maxInMemoryLogs = 1000
    
    private init() {}
    
    // MARK: - Logging Methods
    
    func debug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, category: category, file: file, function: function, line: line)
    }
    
    func info(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, category: category, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, category: category, file: file, function: function, line: line)
    }
    
    func error(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, category: category, file: file, function: function, line: line)
    }
    
    func error(_ error: Error, message: String? = nil, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
        let errorMessage = message != nil ? "\(message!) - Error: \(error.localizedDescription)" : "Error: \(error.localizedDescription)"
        log(errorMessage, level: .error, category: category, file: file, function: function, line: line)
    }
    
    // MARK: - Private Methods
    
    private func log(_ message: String, level: LogLevel, category: LogCategory, file: String, function: String, line: Int) {
        // Skip logging if below minimum level
        guard level.rawValue >= minimumLogLevel.rawValue else { return }
        
        // Get filename without path
        let filename = URL(fileURLWithPath: file).lastPathComponent
        
        // Format message with metadata
        let formattedMessage = "\(level.emoji) [\(filename):\(line)] \(function) - \(message)"
        
        // Log to OS log
        os_log("%{public}@", log: osLogger(for: category), type: level.osLogType, formattedMessage)
        
        // Store in memory for debug access
        addToInMemoryLogs(formattedMessage)
        
        // In debug mode, also print to console
        #if DEBUG
        print(formattedMessage)
        #endif
    }
    
    private func osLogger(for category: LogCategory) -> OSLog {
        switch category {
        case .network: return networkLogger
        case .ui: return uiLogger
        case .playback: return playbackLogger
        case .cache: return cacheLogger
        case .general: return generalLogger
        }
    }
    
    private func addToInMemoryLogs(_ message: String) {
        inMemoryLogs.append(message)
        
        // Trim if exceeds max capacity
        if inMemoryLogs.count > maxInMemoryLogs {
            inMemoryLogs.removeFirst(inMemoryLogs.count - maxInMemoryLogs)
        }
    }
    
    // MARK: - Public Methods for Debug UI
    
    func getInMemoryLogs() -> [String] {
        return inMemoryLogs
    }
    
    func clearInMemoryLogs() {
        inMemoryLogs.removeAll()
    }
    
    func setMinimumLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
    }
}

enum LogCategory {
    case network
    case ui
    case playback
    case cache
    case general
}

// Convenience global functions
func logDebug(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.debug(message, category: category, file: file, function: function, line: line)
}

func logInfo(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.info(message, category: category, file: file, function: function, line: line)
}

func logWarning(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.warning(message, category: category, file: file, function: function, line: line)
}

func logError(_ message: String, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(message, category: category, file: file, function: function, line: line)
}

func logError(_ error: Error, message: String? = nil, category: LogCategory = .general, file: String = #file, function: String = #function, line: Int = #line) {
    Logger.shared.error(error, message: message, category: category, file: file, function: function, line: line)
}
