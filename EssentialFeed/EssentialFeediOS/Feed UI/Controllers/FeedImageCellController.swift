//
//  FeedImageCellController.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//

import Foundation
import UIKit
import EssentialFeed

public protocol FeedImageDataControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageView {
    
    public typealias Image = UIImage
    private var cell: FeedImageCell?
    
    private var delegate: FeedImageDataControllerDelegate
    
    public init(delegate: FeedImageDataControllerDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        cancelLoading()
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    public func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.url = model.url
        cell?.imageContainer.isShimmering = model.isLoading
        cell?.feedImageView.setImage(model.image)
        cell?.retryButton.isHidden = !model.shouldRetry
        
        cell?.onRetryButtonTapped = { [weak self] in
            self?.prefetch()
        }
        cell?.onPrepareForReused = {[weak self] in
            self?.cancelLoading()
        }
    }

    
    func prefetch() {
        delegate.didRequestImage()
    }
    
    func cancelLoading() {
        cell = nil
        delegate.didCancelImageRequest()
    }
    
    func releaseCellForReuse() {
        cell?.onPrepareForReused = nil
        cell = nil
    }
   
}
