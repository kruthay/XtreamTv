//
//  SeriesItemView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//
import SwiftUI

struct SeriesItemView: View {
    let series: Series
    @State private var imageLoadError = false
    
    var body: some View {
        VStack {
            // Series poster
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2/3, contentMode: .fit)
                    .cornerRadius(8)
                
                if let thumbnailURL = series.thumbnailURL, !imageLoadError {
                    CachedAsyncImage(url: thumbnailURL) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        // Remove the "phase" parameter here
                        ProgressView()
                    }
                    .aspectRatio(2/3, contentMode: .fit)
                    .cornerRadius(8)
                } else {
                    Image(systemName: "play.tv")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .cornerRadius(8)
            .shadow(radius: 3)
            
            // Series title
            Text(series.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 40)
        }
        .frame(width: 150)
    }
}

