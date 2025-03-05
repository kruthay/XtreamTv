// Views/Movies/MovieDetailView.swift
import SwiftUI
import AVKit

struct MovieDetailView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    @Environment(\.presentationMode) var presentationMode
    
    let movie: Movie
    
    @State private var isFavorite = false
    @State private var isPlaying = false
    
    var body: some View {
        Spacer()
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Main content
                VStack(spacing: 0) {
                    if isPlaying {
                        // Video player section - full width
                        VideoPlayerContainerView()
                            .frame(width: geometry.size.width, height: geometry.size.width * 9/16)
                    } else {
                        // Movie poster/thumbnail view - full width poster
                        ZStack {
                            Color.black
                            
                            // Movie poster with optimized sizing
                            if let thumbnailURL = movie.thumbnailURL {
                                CachedAsyncImage(url: thumbnailURL) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: geometry.size.width)
                                        .clipped()
                                } placeholder: {
                                    ZStack {
                                        Color.gray.opacity(0.3)
                                        ProgressView()
                                    }
                                }
                            } else {
                                ZStack {
                                    Color.gray.opacity(0.3)
                                    Image(systemName: "film")
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                }
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
                        .frame(height: geometry.size.height * 0.45) // Allocate 45% of screen height to poster
                    }
                    
                    if !isPlaying {
                        // Movie title and action buttons - compact layout
                        VStack(alignment: .leading, spacing: 0) {
                            Text(movie.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 12)
                                .padding(.horizontal)
                            
                            // Action buttons in compact row
                            HStack(spacing: 40) {
                                Button(action: {
                                    viewModel.toggleFavorite(movieID: movie.id)
                                    isFavorite.toggle()
                                }) {
                                    Image(systemName: isFavorite ? "star.fill" : "star")
                                        .foregroundColor(isFavorite ? .yellow : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.systemBackground))
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    startPlayback()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 20))
                                        Text("Play")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                            
                            Divider()
                            
                            // Movie metadata in compact grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 16),
                                GridItem(.flexible(), spacing: 16)
                            ], spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Category")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(viewModel.getCategoryName(for: movie.categoryID))
                                        .font(.subheadline)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Format")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(movie.containerExtension.uppercased())
                                        .font(.subheadline)
                                }
                                
                                if let addedDate = movie.addedDate {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Added")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(formatDate(addedDate))
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // Custom back button overlay at top
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(16)
                    }
                    .padding(.leading, 12)
                    .padding(.top, 12)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true) // Hide default navigation bar completely
        .statusBar(hidden: true) // Hide status bar for more screen space
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
