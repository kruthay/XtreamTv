// VideoPlayerContainerView.swift
import SwiftUI
import AVKit

// Define PlaybackOption enum
enum PlaybackOption: String, CaseIterable, Identifiable {
    case native = "Native Player"
    case vlc = "VLC"
    
    var id: String { self.rawValue }
}

struct VideoPlayerContainerView: View {
    @EnvironmentObject var playbackService: MediaPlaybackService
    @State private var isFullScreen = false
    @State private var showPlaybackOptions = false
    @State private var selectedPlayer: PlaybackOption = .native
    
    var body: some View {
        ZStack {
            // Background
            Color.black
            
            if playbackService.requiresExternalPlayer {
                // External player UI
                externalPlayerView
            } else if let player = playbackService.player {
                // Regular player with enhanced controls
                ZStack {
                    // Video player
                    VideoPlayer(player: player)
                    
                    // Controls overlay conditionally shown
                    ControlsOverlay(
                        isFullScreen: $isFullScreen,
                        showPlaybackOptions: $showPlaybackOptions
                    )
                }
                .fullScreenCover(isPresented: $isFullScreen) {
                    // Full screen player view
                    ZStack {
                        VideoPlayer(player: player)
                        FullScreenControlsOverlay(isFullScreen: $isFullScreen)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)
                }
                .sheet(isPresented: $showPlaybackOptions) {
                    PlaybackOptionsView(
                        selectedOption: $selectedPlayer,
                        onSelect: { option in
                            if option == .vlc {
                                playbackService.openInExternalApp()
                            }
                            showPlaybackOptions = false
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            } else {
                // Loading or error state
                loadingErrorView
            }
        }
        // Setup PIP support when app moves to background
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if let player = playbackService.player, !isFullScreen {
                setupPictureInPicture(for: player)
            }
        }
    }
    
    // External player view
    private var externalPlayerView: some View {
        VStack(spacing: 15) {
            Image(systemName: "play.rectangle.on.rectangle")
                .font(.system(size: 40))
                .foregroundColor(.white)
            
            Text("This stream requires an external player")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: {
                playbackService.openInExternalApp()
            }) {
                Text("Open in External App")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    // Loading or error view
    private var loadingErrorView: some View {
        Group {
            if playbackService.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if let error = playbackService.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.yellow)
                    
                    Text("Playback Error")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Text(error.localizedDescription)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
            } else {
                // Placeholder when not loading but no player is available
                Image(systemName: "tv")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Helper to set up PIP
    private func setupPictureInPicture(for player: AVPlayer) {
        // Check if PIP is supported
        if AVPictureInPictureController.isPictureInPictureSupported() {
            // Configure PIP controller
            let playerLayer = AVPlayerLayer(player: player)
            if let pipController = AVPictureInPictureController(playerLayer: playerLayer) {
                pipController.startPictureInPicture()
            }
        }
    }
}

// Component for video controls overlay
struct ControlsOverlay: View {
    @Binding var isFullScreen: Bool
    @Binding var showPlaybackOptions: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    showPlaybackOptions = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(8)
                
                Button(action: {
                    isFullScreen = true
                }) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            .padding(.top)
            
            Spacer()
        }
    }
}

// Full screen control overlay
struct FullScreenControlsOverlay: View {
    @Binding var isFullScreen: Bool
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isFullScreen = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding()
                
                Spacer()
            }
            
            Spacer()
        }
    }
}

// Playback options view
struct PlaybackOptionsView: View {
    @Binding var selectedOption: PlaybackOption
    var onSelect: (PlaybackOption) -> Void
    
    var body: some View {
        List {
            ForEach(PlaybackOption.allCases) { option in
                Button(action: {
                    selectedOption = option
                    onSelect(option)
                }) {
                    HStack {
                        Text(option.rawValue)
                        Spacer()
                        if selectedOption == option {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Playback Options")
    }
}
