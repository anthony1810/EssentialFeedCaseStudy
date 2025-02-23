//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 20/2/25.
//

import UIKit
import EssentialFeed

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

public final class FeedViewController: UITableViewController {
    var feedLoader: FeedLoader?
    var imageDataLoader: FeedImageDataLoader?
    
    var items: [FeedImage] = []
    var imageDataTasks: [IndexPath: ImageDataLoaderTask] = [:]
    
    public convenience init(feedLoader: FeedLoader, imageDataLoader: FeedImageDataLoader) {
        self.init()
        
        self.feedLoader = feedLoader
        self.imageDataLoader = imageDataLoader
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc
    func load() {
        refreshControl?.beginRefreshing()
        feedLoader?.load { [unowned self] result in
            if case let .success(items) = result {
                self.items = items
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
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
    
    private func loadImageData(for cell: FeedImageCell, at indexPath: IndexPath, with url: URL) {
        let task = imageDataLoader?.loadImageData(from: url) { [cell] completion in
            if let data = try? completion.get(), let image = UIImage(data: data) {
                cell.retryButton.isHidden = true
                cell.feedImageView.image = image
            } else {
                cell.retryButton.isHidden = false
                cell.feedImageView.image = nil
            }
            cell.imageContainer.isShimmering = false
        }
        imageDataTasks[indexPath] = task
    }
}
