//
//  MovieRowView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    
    var body: some View {
        HStack {
            if let thumbnailURL = movie.thumbnailURL {
                CachedAsyncImage(url: thumbnailURL) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image(systemName: "film")
                        .foregroundColor(.gray)
                }
                .frame(width: 60, height: 90)
                .cornerRadius(6)
            } else {
                Image(systemName: "film")
                    .foregroundColor(.blue)
                    .frame(width: 60, height: 90)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading) {
                Text(movie.name)
                    .font(.headline)
                
                // Add movie metadata if available
                if let addedDate = movie.addedDate {
                    Text("Added: \(formatDate(addedDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("Format: \(movie.containerExtension.uppercased())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
