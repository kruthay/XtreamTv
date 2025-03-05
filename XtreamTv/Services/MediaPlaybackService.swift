//
//  MediaPlaybackService.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// MediaPlaybackService.swift
import Foundation
import AVFoundation
import Combine
import UIKit

class MediaPlaybackService: ObservableObject {
    // Published state
    @Published private(set) var currentItem: MediaItem?
    @Published private(set) var player: AVPlayer?
    @Published private(set) var isLoading = false
    @Published private(set) var isPlaying = false
    @Published private(set) var error: Error?
    @Published private(set) var requiresExternalPlayer = false
    @Published private(set) var availableSubtitles: [AVMediaSelectionOption] = []
    
    // Dependencies
    private let backgroundPlaybackManager: BackgroundPlaybackManager
    private let userPreferences: UserPreferencesManager
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    private var timeObserver: Any?
    
    // Error types
    enum PlaybackError: Error, LocalizedError {
        case failedToCreatePlayer
        case mediaNotSupported
        case playbackFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .failedToCreatePlayer:
                return "Failed to create media player"
            case .mediaNotSupported:
                return "This media format is not supported natively"
            case .playbackFailed(let error):
                return "Playback failed: \(error.localizedDescription)"
            }
        }
    }
    
    init(
        backgroundPlaybackManager: BackgroundPlaybackManager = BackgroundPlaybackManager.shared,
        userPreferences: UserPreferencesManager
    ) {
        self.backgroundPlaybackManager = backgroundPlaybackManager
        self.userPreferences = userPreferences
        
        setupNotifications()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Playback Control
    
    func play(item: MediaItem) {
        // Mark this item as recently watched
        userPreferences.addToRecentlyWatched(contentID: item.id)
        
        // Cleanup any previous playback
        cleanup()
        
        // Set current item
        currentItem = item
        isLoading = true
        error = nil
        
        // Check if needs external player
        if needsExternalPlayer(fileExtension: item.fileExtension) {
            requiresExternalPlayer = true
            isLoading = false
            return
        }
        
        // Configure background playback
        backgroundPlaybackManager.setupBackgroundPlayback()
        
        // Create player
        createPlayer(for: item)
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func resume() {
        player?.play()
        isPlaying = true
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func openInExternalApp() {
        guard let item = currentItem else { return }
        
        // Try to open in VLC first
        let vlcURLScheme = "vlc://\(item.streamURL.absoluteString)"
        if let vlcURL = URL(string: vlcURLScheme), UIApplication.shared.canOpenURL(vlcURL) {
            UIApplication.shared.open(vlcURL, options: [:], completionHandler: nil)
            return
        }
        
        // Try Infuse next
        let infuseURLScheme = "infuse://\(item.streamURL.absoluteString)"
        if let infuseURL = URL(string: infuseURLScheme), UIApplication.shared.canOpenURL(infuseURL) {
            UIApplication.shared.open(infuseURL, options: [:], completionHandler: nil)
            return
        }
        
        // Fall back to trying to open the URL directly
        UIApplication.shared.open(item.streamURL, options: [:]) { success in
            if !success {
                // Set error if we couldn't open the URL
                DispatchQueue.main.async {
                    self.error = PlaybackError.mediaNotSupported
                }
            }
        }
    }
    

    func selectSubtitle(_ option: AVMediaSelectionOption?) {
        Task {
            do {
                guard let player = player,
                      let playerItem = player.currentItem else {
                    return
                }
                
                // Try to load the media selection group
                if let group = try await playerItem.asset.loadMediaSelectionGroup(for: .legible) {
                    // Now group is unwrapped and safe to use
                    await MainActor.run {
                        if let option = option {
                            playerItem.select(option, in: group)
                        } else {
                            // Pass nil to disable subtitles
                            playerItem.select(nil, in: group)
                        }
                    }
                } else {
                    // No subtitle group available
                    print("No subtitle selection group available")
                }
            } catch {
                // Handle errors properly
                print("Error selecting subtitle: \(error)")
            }
        }
    }
    
    // MARK: - Player Setup
    
    private func createPlayer(for item: MediaItem) {
        let asset = AVURLAsset(url: item.streamURL)
        let playerItem = AVPlayerItem(asset: asset)
        
        // Configure buffer sizes based on content type
        if item.isLiveStream {
            playerItem.preferredForwardBufferDuration = 4.0
        } else {
            playerItem.preferredForwardBufferDuration = 10.0
        }
        
        // Create and configure player
        let player = AVPlayer(playerItem: playerItem)
        self.player = player
        
        // Optimize settings based on content type
        player.automaticallyWaitsToMinimizeStalling = !item.isLiveStream
        
        // Observe player state
        observePlayback(player: player, playerItem: playerItem)
        
        // Set up time observation for updating Now Playing info
        setupTimeObserver(player: player, for: item)
        
        // Extract subtitles
        extractSubtitles(from: playerItem)
        
        // Load artwork for Now Playing
        if let thumbnailURL = item.thumbnailURL {
            loadArtwork(from: thumbnailURL, for: item.title)
        } else {
            updateNowPlayingInfo(title: item.title)
        }
    }
    
    private func observePlayback(player: AVPlayer, playerItem: AVPlayerItem) {
        // Observe player rate changes
        player.publisher(for: \.rate)
            .receive(on: RunLoop.main)
            .sink { [weak self] rate in
                self?.isPlaying = rate > 0
            }
            .store(in: &cancellables)
        
        // Observe player item status
        playerItem.publisher(for: \.status)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .readyToPlay:
                    self.isLoading = false
                    self.resume() // Auto-play when ready
                    
                case .failed:
                    self.isLoading = false
                    let error = playerItem.error ?? PlaybackError.playbackFailed(NSError(domain: "AVPlayerItemError", code: -1, userInfo: nil))
                    self.handlePlaybackError(error)
                    
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // Observe playback errors
        NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error {
                    self?.handlePlaybackError(error)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupTimeObserver(player: AVPlayer, for item: MediaItem) {
        // Remove any existing observer
        removeTimeObserver()
        
        // Don't add time observer for live content
        if item.isLiveStream {
            return
        }
        
        // Add time observer
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self,
                  let item = self.currentItem,
                  let duration = player.currentItem?.duration.seconds,
                  duration.isFinite else {
                return
            }
            
            self.updateNowPlayingInfo(
                title: item.title,
                currentTime: time.seconds,
                duration: duration
            )
        }
    }
    
    private func extractSubtitles(from playerItem: AVPlayerItem) {
        Task {
            do {
                // Use try with the async call that can throw
                if let group = try await playerItem.asset.loadMediaSelectionGroup(for: .legible) {
                    await MainActor.run {
                        self.availableSubtitles = group.options
                    }
                } else {
                    await MainActor.run {
                        self.availableSubtitles = []
                    }
                }
            } catch {
                // Handle errors properly
                print("Error loading subtitles: \(error)")
                await MainActor.run {
                    self.availableSubtitles = []
                    // Don't let subtitle loading failure affect main playback
                    // Just log the error and continue
                }
            }
        }
    }

    
    // MARK: - Now Playing Info
    
    private func loadArtwork(from url: URL, for title: String) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.updateNowPlayingInfo(title: title, artwork: image)
            }
        }.resume()
    }
    
    private func updateNowPlayingInfo(
        title: String,
        currentTime: Double = 0,
        duration: Double = 0,
        artwork: UIImage? = nil
    ) {
        guard let item = currentItem, !item.isLiveStream else {
            return
        }
        
        backgroundPlaybackManager.updateNowPlayingInfo(
            title: title,
            duration: duration,
            elapsedTime: currentTime,
            artworkImage: artwork
        )
    }
    
    // MARK: - Error Handling
    
    private func handlePlaybackError(_ error: Error) {
        self.error = error
        
        // If we have alternative URLs, try the next one
        if let item = currentItem,
           !item.alternativeURLs.isEmpty,
           let originalURL = player?.currentItem?.asset as? AVURLAsset {
            
            // Find alternative URLs we haven't tried yet
            let remainingURLs = item.alternativeURLs.filter { $0 != originalURL.url }
            
            if !remainingURLs.isEmpty {
                // Create a new media item with the next URL to try
                let newItem = MediaItem(
                    id: item.id,
                    title: item.title,
                    streamURL: remainingURLs[0],
                    alternativeURLs: Array(remainingURLs.dropFirst()),
                    thumbnailURL: item.thumbnailURL,
                    contentType: item.contentType,
                    fileExtension: item.fileExtension
                )
                
                // Try with this new URL
                play(item: newItem)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func needsExternalPlayer(fileExtension: String?) -> Bool {
        guard let ext = fileExtension else { return false }
        return ext.lowercased() == "mkv"
    }
    
    private func setupNotifications() {
        // Handle remote control events
        NotificationCenter.default.publisher(for: .playCommandReceived)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.resume()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .pauseCommandReceived)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pause()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .togglePlayPauseCommandReceived)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.togglePlayPause()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .audioInterruptionBegan)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.pause()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .audioInterruptionEnded)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                if let shouldResume = notification.object as? Bool, shouldResume {
                    self?.resume()
                }
            }
            .store(in: &cancellables)
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver, let player = player {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        // Stop playback
        pause()
        
        // Remove observers
        removeTimeObserver()
        cancellables.removeAll()
        
        // Reset state
        player = nil
        currentItem = nil
        error = nil
        isLoading = false
        isPlaying = false
        requiresExternalPlayer = false
        availableSubtitles = []
    }
}
