//
//  SeriesDetailView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct SeriesDetailView: View {
    @EnvironmentObject var viewModel: SeriesViewModel
    
    let series: Series
    
    @State private var seriesInfo: SeriesInfo?
    @State private var isLoading = true
    @State private var isFavorite = false
    @State private var selectedSeason: String?
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with cover image
                ZStack(alignment: .bottomLeading) {
                    // Cover image
                    if let thumbnailURL = series.thumbnailURL {
                        CachedAsyncImage(url: thumbnailURL) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 220)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 220)
                    }
                    
                    // Gradient overlay
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 220)
                    
                    // Title overlay
                    VStack(alignment: .leading) {
                        Text(series.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let releaseDate = series.releaseDate {
                            Text(releaseDate)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                }
                
                // Loading state
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading series info...")
                        Spacer()
                    }
                    .padding()
                } else if let error = errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Details")
                            .font(.headline)
                        
                        Text(error)
                            .font(.body)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            loadSeriesInfo()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    // Series info
                    seriesInfoView
                }
            }
        }
        .navigationTitle(series.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadSeriesInfo()
            isFavorite = viewModel.isFavorite(seriesID: series.id)
            viewModel.addToRecentlyWatched(seriesID: series.id)
        }
    }
    
    private var seriesInfoView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Plot/description
            if let plot = series.plot, !plot.isEmpty {
                Text("Description")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text(plot)
                    .font(.body)
                    .padding(.horizontal)
            } else if let info = seriesInfo, let plot = info.info.plot, !plot.isEmpty {
                Text("Description")
                    .font(.headline)
                    .padding(.horizontal)
                
                Text(plot)
                    .font(.body)
                    .padding(.horizontal)
            }
            
            // Genre & Rating
            HStack {
                if let genre = series.genre, !genre.isEmpty {
                    Text(genre)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let rating = series.rating, !rating.isEmpty {
                    Text("Rating: \(rating)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Favorite button
            Button(action: {
                viewModel.toggleFavorite(seriesID: series.id)
                isFavorite.toggle()
            }) {
                Label(
                    isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: isFavorite ? "star.fill" : "star"
                )
                .foregroundColor(isFavorite ? .yellow : .primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Season picker
            if let seasons = seriesInfo?.episodes, !seasons.isEmpty {
                seasonPickerView(seasons: Array(seasons.keys))
                
                // Episodes list
                if let selectedSeason = selectedSeason, let episodes = seriesInfo?.episodes[selectedSeason] {
                    episodesListView(episodes: episodes)
                }
            }
        }
    }
    
    private func seasonPickerView(seasons: [String]) -> some View {
        VStack(alignment: .leading) {
            Text("Seasons")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(seasons.sorted(), id: \.self) { season in
                        Button(action: {
                            selectedSeason = season
                        }) {
                            Text("Season \(season)")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(selectedSeason == season ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedSeason == season ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // Select first season by default if nothing is selected
            if selectedSeason == nil, let firstSeason = seasons.sorted().first {
                selectedSeason = firstSeason
            }
        }
    }
    
    private func episodesListView(episodes: [Episode]) -> some View {
        VStack(alignment: .leading) {
            Text("Episodes")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            ForEach(episodes, id: \.id) { episode in
                NavigationLink(destination: EpisodeDetailView(episode: episode, seriesName: series.name)) {
                    EpisodeRowView(episode: episode)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    private func loadSeriesInfo() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let info = try await viewModel.getSeriesInfo(seriesID: series.seriesID)
                await MainActor.run {
                    self.seriesInfo = info
                    
                    // Select the first season by default
                    if selectedSeason == nil, let firstSeason = info.episodes.keys.sorted().first {
                        self.selectedSeason = firstSeason
                    }
                    
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
