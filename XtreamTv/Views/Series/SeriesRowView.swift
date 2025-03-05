//
//  SeriesRowView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct SeriesRowView: View {
    let series: Series
    
    var body: some View {
        HStack {
            if let thumbnailURL = series.thumbnailURL {
                CachedAsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image(systemName: "play.tv")
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 90)
                .cornerRadius(6)
            } else {
                Image(systemName: "play.tv")
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 90)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading) {
                Text(series.name)
                    .font(.headline)
                
                if let genre = series.genre {
                    Text(genre)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let rating = series.rating, !rating.isEmpty {
                    Text("Rating: \(rating)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
