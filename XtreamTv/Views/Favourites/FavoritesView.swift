// Views/Favorites/FavoritesView.swift
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel
    
    @State private var selectedTab: FavoriteTab = .favorites
    @State private var contentType: ContentType = .all
    
    enum FavoriteTab: String, CaseIterable {
        case favorites = "Favorites"
        case recent = "Recently Watched"
    }
    
    enum ContentType: String, CaseIterable {
        case all = "All"
        case liveTV = "Live TV"
        case movies = "Movies"
        case series = "Series"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Tab selector
                Picker("View Type", selection: $selectedTab) {
                    ForEach(FavoriteTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Content type filter
                Picker("Content Type", selection: $contentType) {
                    ForEach(ContentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content based on selected tab and filter
                if selectedTab == .favorites {
                    favoritesContent
                } else {
                    recentlyWatchedContent
                }
            }
            .navigationTitle(selectedTab.rawValue)
            .onAppear {
                favoritesViewModel.refresh()
            }
        }
    }
    
    private var favoritesContent: some View {
        Group {
            if hasNoFavorites() {
                emptyFavoritesView
            } else {
                favoritesListView
            }
        }
    }
    
    private var recentlyWatchedContent: some View {
        Group {
            if hasNoRecentItems() {
                emptyRecentView
            } else {
                recentlyWatchedListView
            }
        }
    }
    
    private var emptyFavoritesView: some View {
        ContentUnavailableView(
            "No Favorites",
            systemImage: "star",
            description: Text("You haven't added any items to your favorites yet")
        )
    }
    
    private var emptyRecentView: some View {
        ContentUnavailableView(
            "No Recent Items",
            systemImage: "clock",
            description: Text("You haven't watched any content yet")
        )
    }
    
    private var favoritesListView: some View {
        List {
            // Live TV Section
            if shouldShowLiveTV() && !filteredFavoriteChannels.isEmpty {
                Section(header: Text("Live TV")) {
                    ForEach(filteredFavoriteChannels) { channel in
                        NavigationLink(destination: ChannelDetailView(channel: channel)) {
                            ChannelRowView(channel: channel)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                favoritesViewModel.removeFavorite(id: channel.id)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            
            // Movies Section
            if shouldShowMovies() && !filteredFavoriteMovies.isEmpty {
                Section(header: Text("Movies")) {
                    ForEach(filteredFavoriteMovies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieRowView(movie: movie)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                favoritesViewModel.removeFavorite(id: movie.id)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            
            // Series Section
            if shouldShowSeries() && !filteredFavoriteSeries.isEmpty {
                Section(header: Text("Series")) {
                    ForEach(filteredFavoriteSeries) { series in
                        NavigationLink(destination: SeriesDetailView(series: series)) {
                            SeriesRowView(series: series)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                favoritesViewModel.removeFavorite(id: series.id)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var recentlyWatchedListView: some View {
        List {
            // Live TV Section
            if shouldShowLiveTV() && !filteredRecentChannels.isEmpty {
                Section(header: Text("Live TV")) {
                    ForEach(filteredRecentChannels) { channel in
                        NavigationLink(destination: ChannelDetailView(channel: channel)) {
                            ChannelRowView(channel: channel)
                        }
                    }
                }
            }
            
            // Movies Section
            if shouldShowMovies() && !filteredRecentMovies.isEmpty {
                Section(header: Text("Movies")) {
                    ForEach(filteredRecentMovies) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieRowView(movie: movie)
                        }
                    }
                }
            }
            
            // Series Section
            if shouldShowSeries() && !filteredRecentSeries.isEmpty {
                Section(header: Text("Series")) {
                    ForEach(filteredRecentSeries) { series in
                        NavigationLink(destination: SeriesDetailView(series: series)) {
                            SeriesRowView(series: series)
                        }
                    }
                }
            }
        }
    }
    
    // Helper functions for filtering
    
    private var filteredFavoriteChannels: [Channel] {
        favoritesViewModel.favoriteChannels
    }
    
    private var filteredFavoriteMovies: [Movie] {
        favoritesViewModel.favoriteMovies
    }
    
    private var filteredFavoriteSeries: [Series] {
        favoritesViewModel.favoriteSeries
    }
    
    private var filteredRecentChannels: [Channel] {
        favoritesViewModel.recentChannels
    }
    
    private var filteredRecentMovies: [Movie] {
        favoritesViewModel.recentMovies
    }
    
    private var filteredRecentSeries: [Series] {
        favoritesViewModel.recentSeries
    }
    
    private func hasNoFavorites() -> Bool {
        if contentType == .all {
            return filteredFavoriteChannels.isEmpty &&
                   filteredFavoriteMovies.isEmpty &&
                   filteredFavoriteSeries.isEmpty
        } else if contentType == .liveTV {
            return filteredFavoriteChannels.isEmpty
        } else if contentType == .movies {
            return filteredFavoriteMovies.isEmpty
        } else { // series
            return filteredFavoriteSeries.isEmpty
        }
    }
    
    private func hasNoRecentItems() -> Bool {
        if contentType == .all {
            return filteredRecentChannels.isEmpty &&
                   filteredRecentMovies.isEmpty &&
                   filteredRecentSeries.isEmpty
        } else if contentType == .liveTV {
            return filteredRecentChannels.isEmpty
        } else if contentType == .movies {
            return filteredRecentMovies.isEmpty
        } else { // series
            return filteredRecentSeries.isEmpty
        }
    }
    
    private func shouldShowLiveTV() -> Bool {
        return contentType == .all || contentType == .liveTV
    }
    
    private func shouldShowMovies() -> Bool {
        return contentType == .all || contentType == .movies
    }
    
    private func shouldShowSeries() -> Bool {
        return contentType == .all || contentType == .series
    }
}

// For iOS versions without ContentUnavailableView (pre-iOS 17)
// Remove this if targeting iOS 17+ only
struct ContentUnavailableView<Description: View>: View {
    let title: String
    let systemImage: String
    let description: Description
    
    init(_ title: String, systemImage: String, description: Description) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            description
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
