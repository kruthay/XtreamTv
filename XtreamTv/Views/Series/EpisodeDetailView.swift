//
//  EpisodeDetailView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI
import AVKit

struct EpisodeDetailView: View {
    @EnvironmentObject var viewModel: SeriesViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    
    let episode: Episode
    let seriesName: String
    
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            if isPlaying {
                // Video player section
                VideoPlayerContainerView()
                    .aspectRatio(16/9, contentMode: .fit)
            } else {
                // Episode thumbnail view
                ZStack {
                    Color.black.opacity(0.8)
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    // Episode thumbnail or placeholder
                    if let infoURL = episode.info.movieImage, !infoURL.isEmpty, let url = URL(string: infoURL) {
                        CachedAsyncImage(url: url) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ZStack {
                                Color.gray.opacity(0.3)
                                ProgressView()
                            }
                        }
                        .frame(height: 200)
                    } else {
                        ZStack {
                            Color.gray.opacity(0.3)
                            Image(systemName: "play.tv")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                        }
                        .frame(height: 200)
                    }
                    
                    // Play button overlay
                    Button(action: {
                        startPlayback()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 5)
                    }
                }
                .aspectRatio(16/9, contentMode: .fit)
            }
            
            if !isPlaying {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(seriesName) - S\(episode.seasonNum)E\(episode.episodeNum)")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text(episode.title)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Episode details
                        if let plot = episode.info.plot, !plot.isEmpty {
                            Text(plot)
                                .font(.body)
                                .padding(.horizontal)
                        }
                        
                        HStack {
                            if let duration = episode.info.duration, !duration.isEmpty {
                                Label(duration, systemImage: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if let releaseDate = episode.info.releaseDate, !releaseDate.isEmpty {
                                Text(releaseDate)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Play button
                        Button(action: {
                            startPlayback()
                        }) {
                            Label("Play Episode", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Episode \(episode.episodeNum)")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Clean up when leaving the view
            if isPlaying {
                playbackService.cleanup()
                isPlaying = false
            }
        }
    }
    
    private func startPlayback() {
        // Create media item
        guard let mediaItem = viewModel.createMediaItem(
            from: episode,
            seriesName: seriesName
        ) else {
            return
        }
        
        // Start playback
        playbackService.play(item: mediaItem)
        isPlaying = true
    }
}
