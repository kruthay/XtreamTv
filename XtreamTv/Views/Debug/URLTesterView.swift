//
//  URLTesterView.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

import SwiftUI

struct URLTestingView: View {
    @State private var testURL = ""
    @State private var testResult: String?
    @State private var isLoading = false
    
    var body: some View {
        Form {
            Section(header: Text("Network Test")) {
                TextField("Enter URL to test", text: $testURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                Button("Test Connection") {
                    testConnection()
                }
                .disabled(testURL.isEmpty || isLoading)
            }
            
            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Testing connection...")
                        Spacer()
                    }
                }
            } else if let result = testResult {
                Section(header: Text("Result")) {
                    Text(result)
                        .foregroundColor(result.contains("Success") ? .green : .red)
                }
            }
        }
        .navigationTitle("URL Tester")
    }
    
    private func testConnection() {
        guard let url = URL(string: testURL) else {
            testResult = "Error: Invalid URL format"
            return
        }
        
        isLoading = true
        testResult = nil
        
        URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    testResult = "Error: \(error.localizedDescription)"
                } else if let httpResponse = response as? HTTPURLResponse {
                    testResult = "Success: Status code \(httpResponse.statusCode)"
                } else {
                    testResult = "Unknown result"
                }
            }
        }.resume()
    }
}
