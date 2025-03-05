//
//  SearchView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/Search/SearchView.swift
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                SearchBar(searchText: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Search results
                if viewModel.searchText.isEmpty {
                    emptySearchView
                } else if viewModel.isSearching {
                    searchingView
                } else if !viewModel.hasResults() {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Search")
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Search IPTV Content")
                .font(.title2)
            
            Text("Enter a search term to find channels, movies, or series")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var searchingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Searching...")
                .foregroundColor(.secondary)
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Results")
                .font(.title2)
            
            Text("No matches found for '\(viewModel.searchText)'")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var searchResultsList: some View {
        List {
            // Live Channels
            if !viewModel.channelResults.isEmpty {
                Section(header: Text("Live TV")) {
                    ForEach(viewModel.channelResults) { channel in
                        NavigationLink(destination: ChannelDetailView(channel: channel)) {
                            ChannelRowView(channel: channel)
                        }
                    }
                }
            }
            
            // Movies
            if !viewModel.movieResults.isEmpty {
                Section(header: Text("Movies")) {
                    ForEach(viewModel.movieResults) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            MovieRowView(movie: movie)
                        }
                    }
                }
            }
            
            // Series
            if !viewModel.seriesResults.isEmpty {
                Section(header: Text("Series")) {
                    ForEach(viewModel.seriesResults) { series in
                        NavigationLink(destination: SeriesDetailView(series: series)) {
                            SeriesRowView(series: series)
                        }
                    }
                }
            }
        }
    }
}

