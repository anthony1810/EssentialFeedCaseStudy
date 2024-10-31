//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//

import Foundation
import UIKit

final class FeedImageCellController {
    private var viewModel: FeedImageCellViewModel
    
    init(viewModel: FeedImageCellViewModel) {
        self.viewModel = viewModel
    }
    
    deinit {
        cancelLoading()
    }
    
    func view() -> UITableViewCell {
        let cell = FeedImageCell()
        bind(to: cell)
        
        return cell
    }
    
    func bind(to cell: FeedImageCell) {
        cell.locationLabel.text = viewModel.location
        cell.descrtipionLabel.text = viewModel.description
        cell.url = viewModel.imageURL
        cell.imageContainer.isShimmering = true
        cell.feedImageView.image = nil
        cell.retryButton.isHidden = true
        
        viewModel.onImageLoaded = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        
        viewModel.onLoadingStateChanged = { [weak cell] isLoading in
            cell?.imageContainer.isShimmering = isLoading
        }
        
        viewModel.shouldShowRetryStateChange = { [weak cell] shouldShow in
            cell?.retryButton.isHidden = !shouldShow
        }
        
        let loadImage = { [viewModel] in
            viewModel.startImageDownloadTask()
        }
        
        cell.onRetryButtonTapped = loadImage
        loadImage()
    }
    
    func prefetch() {
        viewModel.prefetchImage()
    }
    
    func cancelLoading() {
        viewModel.cancelLoadingImageTask()
    }
   
}

