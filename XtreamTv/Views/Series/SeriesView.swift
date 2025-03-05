import SwiftUI

struct SeriesView: View {
    @EnvironmentObject var viewModel: SeriesViewModel
    
    @State private var searchText = ""
    @State private var showingSettings = false
    
    private let gridColumns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Custom header with search
                    headerView
                    
                    Group {
                        if viewModel.categories.isEmpty && viewModel.isLoading {
                            loadingView
                        } else if viewModel.categories.isEmpty {
                            emptyView
                        } else {
                            categoryGridView
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .navigationBarHidden(true)
        }
        .task {
            if viewModel.seriesList.isEmpty {
                await viewModel.loadData()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("TV Series")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.trailing, 8)
                } else {
                    Button(action: {
                        Task {
                            await viewModel.loadData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 8)
                }
                
                // If you want a settings button, show it:
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 16))
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search series...", text: $searchText)
                    .font(.system(size: 16))
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
        )
    }
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .padding()
            Text("Loading categories...")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "tv.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Series")
                .font(.title2)
            
            Text("No TV series are available. Try refreshing or check your connection.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await viewModel.loadData()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
    private var categoryGridView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // "All Series" block
                NavigationLink(destination: SeriesListView(categoryID: nil, categoryName: "All Series")) {
                    HStack {
                        Text("All Series")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }

                // Horizontal scroll with featured series
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        let filteredSeries = viewModel.seriesList
                            .filter {
                                searchText.isEmpty ||
                                $0.name.localizedCaseInsensitiveContains(searchText)
                            }
                            .prefix(10)
                        ForEach(filteredSeries, id: \.id) { series in
                            NavigationLink(destination: SeriesDetailView(series: series)) {
                                FeaturedSeriesItem(series: series)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.bottom, 16)
                }

                Divider()
                    .padding(.bottom, 8)

                // "Categories"
                Text("Categories")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.bottom, 8)

                LazyVGrid(columns: gridColumns, spacing: 16) {
                    let filteredCategories = viewModel.categories.filter {
                        searchText.isEmpty ||
                        $0.name.localizedCaseInsensitiveContains(searchText)
                    }

                    ForEach(filteredCategories) { category in
                        NavigationLink(destination: SeriesListView(categoryID: category.id, categoryName: category.name)) {
                            CategoryItemForSeries(category: category)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal)
            .alert(isPresented: .constant(viewModel.error != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.error?.localizedDescription ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

}

// A “featured” item for series, similar to FeaturedMovieItem/FeaturedChannelItem
struct FeaturedSeriesItem: View {
    let series: Series
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                if let thumbnailURL = series.thumbnailURL {
                    CachedAsyncImage(url: thumbnailURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                    } placeholder: {
                        ZStack {
                            Color.gray.opacity(0.3)
                            Image(systemName: "tv")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                } else {
                    ZStack {
                        Color.gray.opacity(0.3)
                        Image(systemName: "tv")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                }
            }
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Text(series.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
                .foregroundColor(.primary)
        }
        .frame(width: 120)
    }
}

// A category item for series, modeled after CategoryItem in MoviesView
struct CategoryItemForSeries: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.7),
                            Color.purple.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                
                Image(systemName: "play.tv")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            .aspectRatio(16/9, contentMode: .fill)
            .frame(height: 100)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Text(category.name)
                .font(.callout)
                .fontWeight(.medium)
                .lineLimit(2)
                .padding(.vertical, 8)
                .foregroundColor(.primary)
        }
    }
}
