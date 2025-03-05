//
//  XtreamTvApp.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

@main
struct XtreamTvApp: App {
    let container = DependencyContainer()
        
        // App setup manager
        let appSetupManager = AppSetupManager()
        
        // Debug flag
        #if DEBUG
        @State private var showDebugMenu = false
        #endif
        
        init() {
            // Configure app
            appSetupManager.setupApp()
        }
        
        var body: some Scene {
            WindowGroup {
                ZStack {
                    ContentView()
                        .environmentObject(container.authViewModel)
                        .environmentObject(container.liveChannelsViewModel)
                        .environmentObject(container.moviesViewModel)
                        .environmentObject(container.seriesViewModel)
                        .environmentObject(container.searchViewModel)
                        .environmentObject(container.favoritesViewModel)
                        .environmentObject(container.mediaPlaybackService)
                    
                }
            }
        }
    }
