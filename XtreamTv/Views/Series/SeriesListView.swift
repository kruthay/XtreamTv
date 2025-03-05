//
//  SeriesListView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct SeriesListView: View {
    @EnvironmentObject var viewModel: SeriesViewModel
    
    let categoryID: String?
    let categoryName: String
    
    @State private var isLoadingSeries = false
    @State private var errorMessage: String? = nil
    
    // Grid layout configuration
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 16)
    ]
    
    var filteredSeries: [Series] {
        return viewModel.getSeriesForCategory(categoryID)
    }
    
    var body: some View {
        Group {
            if isLoadingSeries {
                loadingView
            } else if let error = errorMessage {
                errorView(message: error)
            } else if filteredSeries.isEmpty {
                emptyView
            } else {
                seriesGridView
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            isLoadingSeries = true
            Task {
                await viewModel.loadData()
                isLoadingSeries = false
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading series...")
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error Loading Content")
                .font(.headline)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("Try Again") {
                isLoadingSeries = true
                errorMessage = nil
                Task {
                    await viewModel.loadData()
                    isLoadingSeries = false
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tv.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Series")
                .font(.title2)
            
            Text("No series found in this category.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var seriesGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredSeries) { series in
                    NavigationLink(destination: SeriesDetailView(series: series)) {
                        SeriesItemView(series: series)
                    }
                }
            }
            .padding()
        }
    }
}

