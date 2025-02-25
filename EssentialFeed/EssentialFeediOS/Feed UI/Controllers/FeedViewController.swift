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
    var cellControllers: [IndexPath: FeedImageCellController] = [:]
    
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
        cellController(at: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(at: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
       indexPaths
            .forEach { indexPath in
                cellController(at: indexPath).prefetch()
            }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths
             .forEach { indexPath in
                 removeCellController(at: indexPath)
             }
    }
}

extension FeedViewController {
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        let feed = items[indexPath.row]
        let cellController = FeedImageCellController(imageDataLoader: imageDataLoader!, feed: feed)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func removeCellController(at indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
