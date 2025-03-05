//
//  NetworkReachabilityManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Utilities/NetworkReachabilityManager.swift
import Foundation
import Network
import Combine

enum NetworkStatus {
    case unknown
    case unreachable
    case wifi
    case cellular
}

class NetworkReachabilityManager: ObservableObject {
    static let shared = NetworkReachabilityManager()
    
    @Published private(set) var status: NetworkStatus = .unknown
    @Published private(set) var isReachable = false
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkReachabilityMonitor")
    
    private init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            // Determine the network status
            let status: NetworkStatus
            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    status = .wifi
                } else if path.usesInterfaceType(.cellular) {
                    status = .cellular
                } else {
                    status = .unknown
                }
            } else {
                status = .unreachable
            }
            
            // Update published properties on main thread
            DispatchQueue.main.async {
                self.status = status
                self.isReachable = status == .wifi || status == .cellular
                
                // Log changes
                logInfo("Network status changed: \(status)", category: .network)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

// Extension to make NetworkStatus more readable
extension NetworkStatus: CustomStringConvertible {
    var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .unreachable:
            return "Unreachable"
        case .wifi:
            return "WiFi"
        case .cellular:
            return "Cellular"
        }
    }
}
