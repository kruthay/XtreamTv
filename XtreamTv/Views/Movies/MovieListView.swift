//
//  MovieListView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct MovieListView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    
    let categoryID: String?
    let categoryName: String
    
    @State private var isLoadingMovies = false
    
    var filteredMovies: [Movie] {
        return viewModel.getMoviesForCategory(categoryID)
    }
    
    // Grid layout configuration
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)
    ]
    
    var body: some View {
        Group {
            if isLoadingMovies {
                loadingView
            } else if filteredMovies.isEmpty {
                emptyView
            } else {
                movieGridView
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            isLoadingMovies = true
            Task {
                await viewModel.loadData()
                isLoadingMovies = false
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading movies...")
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Movies")
                .font(.title2)
            
            Text("No movies found in this category.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var movieGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredMovies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieItemView(movie: movie)
                    }
                }
            }
            .padding()
        }
    }
}
