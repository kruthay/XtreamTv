//
//  MovieDetailView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/Movies/MovieDetailView.swift
import SwiftUI
import AVKit

struct MovieDetailView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    
    let movie: Movie
    
    @State private var isFavorite = false
    @State private var isPlaying = false
    
    var body: some View {
        VStack {
            if isPlaying {
                // Video player section
                VideoPlayerContainerView()
                    .aspectRatio(16/9, contentMode: .fit)
            } else {
                // Movie poster/thumbnail view
                ZStack {
                    Color.black.opacity(0.8)
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    // Movie poster or placeholder
                    if let thumbnailURL = movie.thumbnailURL {
                        CachedAsyncImage(url: thumbnailURL) { image in
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
                            Image(systemName: "film")
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
                        Text(movie.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        // Movie metadata
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Category")
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(viewModel.getCategoryName(for: movie.categoryID))
                            }
                            
                            if let addedDate = movie.addedDate {
                                HStack {
                                    Text("Added")
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(formatDate(addedDate))
                                }
                            }
                            
                            HStack {
                                Text("Format")
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(movie.containerExtension.uppercased())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action buttons
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.toggleFavorite(movieID: movie.id)
                                isFavorite.toggle()
                            }) {
                                VStack {
                                    Image(systemName: isFavorite ? "star.fill" : "star")
                                        .font(.system(size: 24))
                                    Text(isFavorite ? "Favorited" : "Favorite")
                                        .font(.caption)
                                }
                                .foregroundColor(isFavorite ? .yellow : .primary)
                                .frame(maxWidth: .infinity)
                            }
                            
                            Button(action: {
                                startPlayback()
                            }) {
                                VStack {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 24))
                                    Text("Play")
                                        .font(.caption)
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                }
            }
        }
        .navigationTitle(movie.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Clean up when leaving the view
            if isPlaying {
                playbackService.cleanup()
                isPlaying = false
            }
        }
        .onAppear {
            // Add to recently watched
            viewModel.addToRecentlyWatched(movieID: movie.id)
            
            // Check if this is a favorite
            isFavorite = viewModel.isFavorite(movieID: movie.id)
        }
    }
    
    private func startPlayback() {
        // Create media item
        guard let mediaItem = viewModel.createMediaItem(from: movie) else {
            return
        }
        
        // Start playback
        playbackService.play(item: mediaItem)
        isPlaying = true
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
