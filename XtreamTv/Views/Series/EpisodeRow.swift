//
//  EpisodeRow.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct EpisodeRowView: View {
    let episode: Episode
    
    var body: some View {
        HStack {
            // Episode thumbnail or placeholder
            if let infoURL = episode.info.movieImage, !infoURL.isEmpty, let url = URL(string: infoURL) {
                CachedAsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 120, height: 68)
                .cornerRadius(8)
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 68)
                    
                    Image(systemName: "play.tv")
                        .foregroundColor(.gray)
                }
                .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(episode.episodeNum). \(episode.title)")
                    .font(.headline)
                
                if let duration = episode.info.duration, !duration.isEmpty {
                    Text("Duration: \(duration)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let plot = episode.info.plot, !plot.isEmpty {
                    Text(plot)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "play.circle")
                .foregroundColor(.blue)
                .font(.title2)
        }
        .padding(.vertical, 8)
    }
}
