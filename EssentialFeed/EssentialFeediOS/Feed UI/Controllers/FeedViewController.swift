//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: FeedRefreshController
    private var imageLoader: FeedImageLoaderProtocol
    
    private var feeds: [FeedImage] = [] {
        didSet { tableView.reloadData() }
    }
    private var loadingImageTasks: [IndexPath: ImageLoadingDataTaskProtocol] = [:]
    private var cellControllers: [IndexPath: FeedImageCellController] = [:]
    
    private var onViewFirstAppear: (() -> Void)?
    
    public init(loader: FeedLoader, imageLoader: FeedImageLoaderProtocol) {
        self.refreshController = FeedRefreshController(loader: loader)
        self.imageLoader = imageLoader
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = refreshController.view
        refreshController.onRefreshComplete = { [weak self] feeds in
            self?.feeds = feeds
        }
        
        tableView.prefetchDataSource = self
        
        onViewFirstAppear = { [weak self] in
            self?.loadFeeds()
            self?.onViewFirstAppear = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewFirstAppear?()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feeds.count
    }
    
    fileprivate func startTask(forCell cell: FeedImageCell, at indexPath: IndexPath) {
        self.loadingImageTasks[indexPath] = self.imageLoader.loadImageData(from: cell.url, completion: { [cell] result in
            
            let imageData = try? result.get()
            let convertedImage = imageData.map(UIImage.init) ?? nil
            cell.feedImageView.image = convertedImage
            
            cell.retryButton.isHidden = convertedImage != nil
            
            cell.imageContainer.isShimmering = false
        })
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellController = FeedImageCellController(feed: feeds[indexPath.row], imageLoader: self.imageLoader)
        cellControllers[indexPath] = cellController
        
        return cellController.view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        cancelLoading(at: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell =  cell as? FeedImageCell else { return }
        
        startTask(forCell: cell, at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            if let cellController = cellControllers[indexPath] {
                cellController.prefetch()
            } else {
                let cellController = FeedImageCellController(feed: feeds[indexPath.row], imageLoader: self.imageLoader)
                cellControllers[indexPath] = cellController
                cellController.prefetch()
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelLoading(at:))
    }
    
    func cancelLoading(at indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
    
    @objc
    public func loadFeeds() {
        refreshController.refresh()
    }
}
