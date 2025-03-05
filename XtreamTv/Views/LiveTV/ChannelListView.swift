//
//  ChannelListView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct ChannelListView: View {
    @EnvironmentObject var viewModel: LiveChannelsViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    
    let categoryID: String?
    let categoryName: String
    
    @State private var isLoadingChannels = false
    
    var filteredChannels: [Channel] {
        return viewModel.getChannelsForCategory(categoryID)
    }
    
    var body: some View {
        Group {
            if isLoadingChannels {
                loadingView
            } else if filteredChannels.isEmpty {
                emptyView
            } else {
                channelListView
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            isLoadingChannels = true
            Task {
                await viewModel.loadData()
                isLoadingChannels = false
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .padding()
            Text("Loading channels...")
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tv.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Channels")
                .font(.title2)
            
            Text("No channels found in this category.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var channelListView: some View {
        List {
            ForEach(filteredChannels) { channel in
                NavigationLink(destination: ChannelDetailView(channel: channel)) {
                    ChannelRowView(channel: channel)
                }
            }
        }
    }
}

