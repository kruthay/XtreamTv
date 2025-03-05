//
//  ChannelDetailView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/LiveTV/ChannelDetailView.swift
import SwiftUI
import AVKit

struct ChannelDetailView: View {
    @EnvironmentObject var viewModel: LiveChannelsViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    
    let channel: Channel
    
    @State private var isPlaying = false
    @State private var isFavorite = false
    
    var body: some View {
        VStack {
            // Playback section
            if isPlaying {
                VideoPlayerContainerView()
                    .frame(height: 230)
            } else {
                // Channel thumbnail/info
                ZStack {
                    Color.black
                        .frame(height: 230)
                    
                    VStack(spacing: 12) {
                        if let thumbnailURL = channel.thumbnailURL {
                            CachedAsyncImage(url: thumbnailURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 80)
                            } placeholder: {
                                Image(systemName: "tv")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            Image(systemName: "tv")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        }
                        
                        Text(channel.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            startPlayback()
                        }) {
                            Label("Play", systemImage: "play.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .frame(height: 230)
            }
            
            // Channel info
            List {
                Section(header: Text("Channel Information")) {
                    HStack {
                        Text("Category")
                        Spacer()
                        Text(viewModel.getCategoryName(for: channel.categoryID))
                            .foregroundColor(.secondary)
                    }
                    
                    if let epgID = channel.epgChannelID, !epgID.isEmpty {
                        HStack {
                            Text("EPG ID")
                            Spacer()
                            Text(epgID)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Stream Type")
                        Spacer()
                        Text(channel.streamType)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Actions section
                Section {
                    Button(action: {
                        viewModel.toggleFavorite(channelID: channel.id)
                        isFavorite.toggle()
                    }) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                    }
                    
                    if !isPlaying {
                        Button(action: {
                            startPlayback()
                        }) {
                            Label("Play Channel", systemImage: "play")
                        }
                    } else {
                        Button(action: {
                            stopPlayback()
                        }) {
                            Label("Stop Playback", systemImage: "stop")
                        }
                    }
                }
            }
        }
        .navigationTitle(channel.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Check if it's a favorite
            isFavorite = viewModel.isFavorite(channelID: channel.id)
            
            // Add to recently watched
            viewModel.addToRecentlyWatched(channelID: channel.id)
        }
        .onDisappear {
            // Stop playback when leaving
            if isPlaying {
                stopPlayback()
            }
        }
    }
    
    private func startPlayback() {
        // Create media item
        guard let mediaItem = viewModel.createMediaItem(from: channel) else {
            return
        }
        
        // Start playback
        playbackService.play(item: mediaItem)
        isPlaying = true
    }
    
    private func stopPlayback() {
        playbackService.cleanup()
        isPlaying = false
    }
}

