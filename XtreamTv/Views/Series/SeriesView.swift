//
//  SeriesView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct SeriesView: View {
    @EnvironmentObject var viewModel: SeriesViewModel
    
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
            .navigationTitle("TV Series")
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
            if viewModel.seriesList.isEmpty {
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
            Image(systemName: "tv.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Series")
                .font(.title2)
            
            Text("No TV series are available. Try refreshing or check your connection.")
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
            // All Series option
            NavigationLink(destination: SeriesListView(categoryID: nil, categoryName: "All Series")) {
                HStack {
                    Image(systemName: "play.tv")
                        .foregroundColor(.blue)
                    Text("All Series")
                        .font(.headline)
                }
            }
            
            // Category list
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: SeriesListView(categoryID: category.id, categoryName: category.name)) {
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
