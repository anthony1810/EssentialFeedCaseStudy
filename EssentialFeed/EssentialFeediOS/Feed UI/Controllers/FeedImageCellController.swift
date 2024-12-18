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

public final class FeedImageCellController: NSObject, ResourceFetchingViewProtocol, ResourceLoadingViewProtocol, LoadResourceErrorViewProtocol {
   
    public typealias ViewModel = UIImage
    public typealias Image = UIImage
    
    private var cell: FeedImageCell?
    
    private var delegate: FeedImageDataControllerDelegate
    private var viewModel: FeedImageViewModel
    
    public init(viewModel: FeedImageViewModel, delegate: FeedImageDataControllerDelegate) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
    
    deinit {
        cancelLoading()
    }
    
    public func display(viewModel: UIImage) {
        cell?.feedImageView.setImage(viewModel)
    }
    
    public func display(_ viewModel: EssentialFeed.ResourceLoadingViewModel) {
        cell?.imageContainer.isShimmering = viewModel.isLoading
    }
    
    public func display(_ viewModel: EssentialFeed.LoadResourceErrorViewModel) {
        cell?.retryButton.isHidden = viewModel.message == nil
    }
    
    private func cancelLoading() {
        cell = nil
        delegate.didCancelImageRequest()
    }
    
    func releaseCellForReuse() {
        cell?.onPrepareForReused = nil
        cell = nil
    }
}

extension FeedImageCellController: CellController {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelLoading()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView.setImage(nil)
        cell?.onRetryButtonTapped = { [weak self] in
            self?.delegate.didRequestImage()
        }
        cell?.onPrepareForReused = {[weak self] in
            self?.cancelLoading()
        }
        delegate.didRequestImage()
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        delegate.didRequestImage()
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelLoading()
    }
}
