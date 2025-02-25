//
//  FeedImageCellController.swift
//  EssentialFeed
//
//  Created by Anthony on 25/2/25.
//
import UIKit

import EssentialFeed

public final class FeedImageCellController {
    
    private var imageDownloadTask: ImageDataLoaderTask?
    private let imageDataLoader: FeedImageDataLoader
    private let feed: FeedImage
    
    public init(
        imageDataLoader: FeedImageDataLoader,
        feed: FeedImage
    ) {
        self.imageDataLoader = imageDataLoader
        self.feed = feed
    }
    
    func cancel() {
        imageDownloadTask?.cancel()
        imageDownloadTask = nil
    }
    
    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = feed.location == nil
        cell.descriptionLabel.text = feed.description
        cell.locationLabel.text = feed.location
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.onRetry = { [unowned self] in
            self.loadImageData(for: cell)
        }
        loadImageData(for: cell)
        
        return cell
    }
    
    func prefetch() {
        imageDownloadTask = imageDataLoader.loadImageData(from: feed.url) { _ in }
    }
    
    private func loadImageData(for cell: FeedImageCell) {
        imageDownloadTask = imageDataLoader.loadImageData(from: feed.url) { completion in
            let data = try? completion.get()
            let image = data.map(UIImage.init) ?? nil
            
            cell.imageContainer.isShimmering = false
            cell.feedImageView.image = image
            cell.retryButton.isHidden = image != nil
        }
    }
    
}
