//
//  LiveChannelsView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/LiveTV/LiveChannelsView.swift
import SwiftUI

struct LiveChannelsView: View {
    @EnvironmentObject var viewModel: LiveChannelsViewModel
    
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
            .navigationTitle("Live TV")
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
            if viewModel.channels.isEmpty {
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
            
            Text("No Live Channels")
                .font(.title2)
            
            Text("No channels are available. Try refreshing or check your connection.")
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
            // All Channels option
            NavigationLink(destination: ChannelListView(categoryID: nil, categoryName: "All Channels")) {
                HStack {
                    Image(systemName: "tv")
                        .foregroundColor(.blue)
                    Text("All Channels")
                        .font(.headline)
                }
            }
            
            // Category list
            ForEach(viewModel.categories) { category in
                NavigationLink(destination: ChannelListView(categoryID: category.id, categoryName: category.name)) {
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

