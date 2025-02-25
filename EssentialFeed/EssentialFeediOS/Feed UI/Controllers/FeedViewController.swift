//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 20/2/25.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    public var refreshViewController: FeedRefreshViewController?
    var feedLoader: FeedLoader?
    var imageDataLoader: FeedImageDataLoader?
    
    var items: [FeedImage] = []
    var imageDataTasks: [IndexPath: ImageDataLoaderTask] = [:]
    
    public convenience init(
        feedLoader: FeedLoader,
        imageDataLoader: FeedImageDataLoader,
        refreshViewController: FeedRefreshViewController
    ) {
        self.init()
        
        self.feedLoader = feedLoader
        self.imageDataLoader = imageDataLoader
        self.refreshViewController = refreshViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = self.refreshViewController?.view
        self.refreshViewController?.onRefresh = { [weak self] items in
            self?.reloadData(with: items)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        load()
    }
    
    @objc
    func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [unowned self] result in
            if case let .success(items) = result {
                reloadData(with: items)
            }
            self.refreshControl?.endRefreshing()
        }
    }
    
    private func reloadData(with items: [FeedImage]) {
        self.items = items
        self.tableView.reloadData()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = items[indexPath.row]
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = feed.location == nil
        cell.descriptionLabel.text = feed.description
        cell.locationLabel.text = feed.location
        cell.imageContainer.isShimmering = true
        cell.retryButton.isHidden = true
        cell.onRetry = { [unowned self] in
            self.loadImageData(for: cell, at: indexPath, with: feed.url)
        }
        loadImageData(for: cell, at: indexPath, with: feed.url)
    
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageDataTasks[indexPath]?.cancel()
        imageDataTasks[indexPath] = nil
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
       indexPaths
            .map { (feed: items[$0.row], indexPath: $0) }
            .forEach { feed, indexPath in
                let cell = FeedImageCell()
                self.loadImageData(for: cell, at: indexPath, with: feed.url)
            }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths
             .map { (feed: items[$0.row], indexPath: $0) }
             .forEach { feed, indexPath in
                 self.imageDataTasks[indexPath]?.cancel()
                 self.imageDataTasks[indexPath] = nil
             }
    }
    
    private func loadImageData(for cell: FeedImageCell, at indexPath: IndexPath, with url: URL) {
        imageDataTasks[indexPath] = imageDataLoader?.loadImageData(from: url) { [cell] completion in
            let data = try? completion.get()
            let image = data.map(UIImage.init) ?? nil
            
            cell.imageContainer.isShimmering = false
            cell.feedImageView.image = image
            cell.retryButton.isHidden = image != nil
        }
    }
}
