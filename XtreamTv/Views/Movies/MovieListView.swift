import SwiftUI

struct MovieListView: View {
    @EnvironmentObject var viewModel: MoviesViewModel
    @EnvironmentObject var playbackService: MediaPlaybackService
    @Environment(\.presentationMode) var presentationMode
    
    let categoryID: String?
    let categoryName: String
    
    @State private var isLoadingMovies = false
    
    var filteredMovies: [Movie] {
        return viewModel.getMoviesForCategory(categoryID)
    }
    
    // Grid layout configuration - 2 columns on phone, more on iPad
    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 180), spacing: 10)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Main content
            Group {
                if isLoadingMovies {
                    loadingView
                } else if filteredMovies.isEmpty {
                    emptyView
                } else {
                    movieGridView
                }
            }
            
            // Custom header overlay
            VStack(spacing: 0) {
                // Custom navigation bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Back")
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text(categoryName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Maintain visual balance with equal width on both sides
                    Button(action: {
                        // For future search or filter functionality
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                    }
                    .opacity(0) // Hidden for now, just for spacing
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(
                    Rectangle()
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                )
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            isLoadingMovies = true
            Task {
                await viewModel.loadData()
                isLoadingMovies = false
            }
        }
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .padding()
            Text("Loading movies...")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50) // Account for custom header
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "film.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Movies")
                .font(.title2)
            
            Text("No movies found in this category.")
                .foregroundColor(.secondary)
                
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50) // Account for custom header
    }
    
    private var movieGridView: some View {
        ScrollView {
            // Add padding at top to account for custom header
            Spacer().frame(height: 50)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredMovies) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        MovieItemView(movie: movie)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
