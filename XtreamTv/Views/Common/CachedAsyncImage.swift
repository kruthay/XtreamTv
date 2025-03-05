//
//  CachedAsyncImage.swift
//  XtreamTv
//
//  Created by Kruthay Kumar Reddy Donapati on 3/4/25.
//

// CachedAsyncImage.swift
import SwiftUI
import Combine

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    @State private var cancellable: AnyCancellable? = nil
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                content(Image(uiImage: image))
            } else {
                placeholder()
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
    
    private func loadImage() {
        guard let url = url, !isLoading else { return }
        
        isLoading = true
        
        // Check cache first
        if let cachedImage = ImageCache.shared.image(for: url) {
            self.image = cachedImage
            isLoading = false
            return
        }
        
        // Load from network
        cancellable = ImageCache.shared.loadImage(from: url)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        print("Error loading image: \(error)")
                    }
                },
                receiveValue: { image in
                    withAnimation(transaction.animation) {
                        self.image = image
                    }
                    isLoading = false
                }
            )
    }
}

extension CachedAsyncImage {
    /// Convenience initializer with simplified content block
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) where Content == Image {
        self.init(
            url: url,
            scale: scale,
            transaction: transaction,
            content: { $0 },
            placeholder: placeholder
        )
    }
}
