//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//

import Foundation
import UIKit

final class FeedImageCellController: FeedImageView {
    
    typealias Image = UIImage
    private var cell: FeedImageCell?
    
    private var delegate: FeedImageDataControllerDelegate
    
    init(delegate: FeedImageDataControllerDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        cancelLoading()
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        self.cell = cell
        delegate.didRequestImage()
        return cell
    }
    
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.url = model.url
        cell?.imageContainer.isShimmering = model.isLoading
        cell?.feedImageView.image = model.image
        cell?.retryButton.isHidden = !model.shouldRetry
        
        cell?.onRetryButtonTapped = delegate.didRequestImage
    }

    
    func prefetch() {
        delegate.didRequestImage()
    }
    
    func cancelLoading() {
        delegate.didCancelImageRequest()
    }
   
}

