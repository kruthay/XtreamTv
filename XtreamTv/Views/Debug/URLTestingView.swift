//
//  URLTestingView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI
import AVKit

struct URLTesterView: View {
    @State private var selectedURL = 0
    @State private var customURL = ""
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var error: Error?
    
    let sampleURLs = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"
    ]
    
    var body: some View {
        VStack {
            Picker("Sample Stream", selection: $selectedURL) {
                Text("Big Buck Bunny").tag(0)
                Text("Elephants Dream").tag(1)
                Text("For Bigger Blazes").tag(2)
                Text("Custom URL").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedURL) { _,_ in
                stopPlayback()
            }
            
            if selectedURL == 3 {
                TextField("Enter custom stream URL", text: $customURL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            if isPlaying, let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(16/9, contentMode: .fit)
                    .onDisappear {
                        stopPlayback()
                    }
            } else {
                ZStack {
                    Color.black
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    VStack {
                        Text(getCurrentURL())
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Button(action: {
                            startPlayback()
                        }) {
                            Text("Test Playback")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                    }
                }
            }
            
            if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
            
            if isPlaying {
                Button("Stop Playback") {
                    stopPlayback()
                }
                .foregroundColor(.red)
                .padding()
            }
        }
        .navigationTitle("Stream Tester")
    }
    
    private func getCurrentURL() -> String {
        if selectedURL == 3 {
            return customURL
        } else {
            return sampleURLs[selectedURL]
        }
    }
    
    private func startPlayback() {
        stopPlayback()
        
        guard let url = URL(string: getCurrentURL()) else {
            self.error = NSError(domain: "URLTesterView", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            return
        }
        
        let player = AVPlayer(url: url)
        self.player = player
        self.isPlaying = true
        self.error = nil
        
        player.play()
    }
    
    private func stopPlayback() {
        player?.pause()
        player = nil
        isPlaying = false
    }
}
