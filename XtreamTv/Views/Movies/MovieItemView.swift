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
        VStack {
            // Movie poster
            if let thumbnailURL = movie.thumbnailURL {
                CachedAsyncImage(url: thumbnailURL) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "film")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(8)
                .shadow(radius: 3)
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "film")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(8)
            }
            
            // Movie title
            Text(movie.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
        .frame(width: 150)
    }
}
