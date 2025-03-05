//
//  PlaybackControlsView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/Playback/PlaybackControlsView.swift
import SwiftUI
import AVKit

struct PlaybackControlsView: View {
    @EnvironmentObject var playbackService: MediaPlaybackService
    @State private var showControls = true
    @State private var hideControlsTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            // Transparent overlay for tapping
            Color.black.opacity(0.01)
                .onTapGesture {
                    withAnimation {
                        showControls.toggle()
                    }
                    
                    if showControls {
                        // Schedule auto-hide
                        scheduleHideControls()
                    } else {
                        // Cancel scheduled hide
                        hideControlsTask?.cancel()
                    }
                }
            
            if showControls {
                // Controls overlay
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // Play/Pause button
                        Button(action: {
                            playbackService.togglePlayPause()
                            scheduleHideControls()
                        }) {
                            Image(systemName: playbackService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 30)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            scheduleHideControls()
        }
        .onDisappear {
            hideControlsTask?.cancel()
        }
    }
    
    private func scheduleHideControls() {
        // Cancel any existing task
        hideControlsTask?.cancel()
        
        // Schedule new hide task
        hideControlsTask = Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation {
                        showControls = false
                    }
                }
            }
        }
    }
}
