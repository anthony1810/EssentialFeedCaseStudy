//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//

import Foundation
import UIKit
import EssentialFeed

final class FeedImageCellController {
    
    private var imageLoader: FeedImageLoaderProtocol
    private var loadingImageTask: ImageLoadingDataTaskProtocol?
    private var feed: FeedImage
    
    init(feed: FeedImage, imageLoader: FeedImageLoaderProtocol) {
        self.imageLoader = imageLoader
        self.feed = feed
    }
    
    deinit {
        cancelLoading()
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = feed.location
        cell.descrtipionLabel.text = feed.description
        cell.url = feed.imageURL
        cell.imageContainer.isShimmering = true
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        let loadImage = { [weak self, weak cell] in
            guard let self, let cell else { return }
            
            startTask(forCell: cell)
        }
        
        cell.onRetryButtonTapped = loadImage
        loadImage()
        
        return cell
    }
    
    fileprivate func startTask(forCell cell: FeedImageCell) {
        self.loadingImageTask = self.imageLoader.loadImageData(from: cell.url, completion: { [cell] result in
            
            let imageData = try? result.get()
            let convertedImage = imageData.map(UIImage.init) ?? nil
            cell.feedImageView.image = convertedImage
            
            cell.retryButton.isHidden = convertedImage != nil
            
            cell.imageContainer.isShimmering = false
        })
    }
    
    func prefetch() {
        self.loadingImageTask = self.imageLoader.loadImageData(from: feed.imageURL) { _ in }
    }
    
    func cancelLoading() {
        loadingImageTask?.cancel()
        loadingImageTask = nil
    }
   
}

final class FeedRefreshController: NSObject {
    
    private(set) var view: UIRefreshControl
    private let loader: FeedLoader
    
    var onRefreshComplete: (([FeedImage]) -> Void)?
    
    init(loader: FeedLoader, refreshController: UIRefreshControl) {
        self.loader = loader
        self.view = refreshController
        
        super.init()
        self.view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        self.view.beginRefreshing()
        loader.load(completion: { [weak self] result in
            if case let .success(feeds) = result {
                self?.onRefreshComplete?(feeds)
            }
            self?.view.endRefreshing()
        })
    }
}
