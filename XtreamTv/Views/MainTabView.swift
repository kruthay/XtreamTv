//
//  MainTabView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// Views/MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            LiveChannelsView()
                .tabItem {
                    Label("Live TV", systemImage: "tv")
                }
            
            MoviesView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            
            SeriesView()
                .tabItem {
                    Label("Series", systemImage: "play.tv")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
