//
//  MovieItemView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct MovieItemView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Movie poster
            ZStack {
                if let thumbnailURL = movie.thumbnailURL {
                    CachedAsyncImage(url: thumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ZStack {
                            Color.gray.opacity(0.3)
                            Image(systemName: "film")
                                .foregroundColor(.gray)
                        }
                    }
                    .aspectRatio(2/3, contentMode: .fill)
                    .cornerRadius(8)
                    .clipped()
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "film")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .aspectRatio(2/3, contentMode: .fill)
                    .cornerRadius(8)
                }
            }
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // Movie title - limit to 2 lines with ellipsis
            Text(movie.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            
            // Format label
            Text(movie.containerExtension.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}
