//
//  ChannelRowView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/LiveTV/ChannelRowView.swift
import SwiftUI

struct ChannelRowView: View {
    let channel: Channel
    
    var body: some View {
        HStack {
            // Channel logo
            if let thumbnailURL = channel.thumbnailURL {
                CachedAsyncImage(url: thumbnailURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "tv")
                        .foregroundColor(.gray)
                }
                .frame(width: 50, height: 50)
                .cornerRadius(6)
            } else {
                Image(systemName: "tv")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .frame(width: 50, height: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            
            // Channel details
            VStack(alignment: .leading, spacing: 4) {
                Text(channel.name)
                    .font(.headline)
                
                HStack {
                    if !channel.streamType.isEmpty {
                        Text(channel.streamType)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if channel.tvArchive {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Channel number
            Text("#\(channel.number)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

