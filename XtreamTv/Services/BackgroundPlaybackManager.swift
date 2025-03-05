//
//  BackgroundPlaybackManager.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// BackgroundPlaybackManager.swift
import Foundation
import AVFoundation
import MediaPlayer

class BackgroundPlaybackManager {
    static let shared = BackgroundPlaybackManager()
    
    private var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    
    private init() {
        setupNotifications()
    }
    
    func setupBackgroundPlayback() {
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.allowAirPlay, .allowBluetooth]
            )
            try audioSession.setActive(true)
            
            setupRemoteTransportControls()
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func updateNowPlayingInfo(
        title: String,
        duration: TimeInterval = 0,
        elapsedTime: TimeInterval = 0,
        artworkImage: UIImage? = nil
    ) {
        var nowPlayingInfo = [String: Any]()
        
        // Add metadata
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        if duration > 0 {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
        }
        
        // Add artwork if available
        if let artwork = artworkImage {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in
                return artwork
            }
        }
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Private Methods
    
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Remove all previous targets
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        commandCenter.skipForwardCommand.removeTarget(nil)
        commandCenter.skipBackwardCommand.removeTarget(nil)
        
        // Add handlers for commands
        commandCenter.playCommand.addTarget { _ in
            NotificationCenter.default.post(name: .playCommandReceived, object: nil)
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { _ in
            NotificationCenter.default.post(name: .pauseCommandReceived, object: nil)
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { _ in
            NotificationCenter.default.post(name: .togglePlayPauseCommandReceived, object: nil)
            return .success
        }
        
        // Configure skip commands
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { _ in
            NotificationCenter.default.post(name: .skipForwardCommandReceived, object: nil)
            return .success
        }
        
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { _ in
            NotificationCenter.default.post(name: .skipBackwardCommandReceived, object: nil)
            return .success
        }
    }
    
    private func setupNotifications() {
        // Listen for route changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        
        // Listen for interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .oldDeviceUnavailable:
            // Headphones were unplugged
            NotificationCenter.default.post(
                name: .audioRouteChanged,
                object: reason
            )
        default:
            break
        }
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            NotificationCenter.default.post(
                name: .audioInterruptionBegan,
                object: nil
            )
            
        case .ended:
            let shouldResume = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt == AVAudioSession.InterruptionOptions.shouldResume.rawValue
            
            NotificationCenter.default.post(
                name: .audioInterruptionEnded,
                object: shouldResume
            )
            
        @unknown default:
            break
        }
    }
}

// Add this at the bottom of BackgroundPlaybackManager.swift
extension Notification.Name {
    static let playCommandReceived = Notification.Name("com.iptv.playCommandReceived")
    static let pauseCommandReceived = Notification.Name("com.iptv.pauseCommandReceived")
    static let togglePlayPauseCommandReceived = Notification.Name("com.iptv.togglePlayPauseCommandReceived")
    static let skipForwardCommandReceived = Notification.Name("com.iptv.skipForwardCommandReceived")
    static let skipBackwardCommandReceived = Notification.Name("com.iptv.skipBackwardCommandReceived")
    static let audioRouteChanged = Notification.Name("com.iptv.audioRouteChanged")
    static let audioInterruptionBegan = Notification.Name("com.iptv.audioInterruptionBegan")
    static let audioInterruptionEnded = Notification.Name("com.iptv.audioInterruptionEnded")
}
