//
//  MoviesView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct MoviesView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.categories.isEmpty && viewModel.isLoading {
                    loadingView
                } else if viewModel.categories.isEmpty {
                    emptyView
                } else {
                    categoryListView
                }
            }
            .navigationTitle("Movies & VOD")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button(action: {
                            Task {
                                await viewModel.loadData()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .alert(isPresented: .constant(viewModel.error != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.error?.localizedDescription ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .task {
            if viewModel.movies.isEmpty {
                await viewModel.loadData()
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading categories...")
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
            
            Text("No movies are available. Try refreshing or check your connection.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Refresh") {
                Task {
                    await viewModel.loadData()
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private var categoryListView: some View {
        List {
            // All Movies option
            NavigationLink(destination: MovieListView(categoryID: nil, categoryName: "All Movies")) {
                HStack {
                    Image(systemName: "film")
                        .foregroundColor(.blue)
                    Text("All Movies")
                        .font(.headline)
                }
            }
            
            // Category list
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: MovieListView(categoryID: category.id, categoryName: category.name)) {
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                        Text(category.name)
                    }
                }
            }
        }
    }
}
