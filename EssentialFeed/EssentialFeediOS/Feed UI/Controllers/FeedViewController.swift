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
    public var tableModels = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var feedLoader: FeedLoader?
    var imageDataLoader: FeedImageDataLoader?
    
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
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.refreshViewController?.refresh()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(at: indexPath)
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
                 cancelCellController(at: indexPath)
             }
    }
}

extension FeedViewController {
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        tableModels[indexPath.row]
    }
    
    private func cancelCellController(at indexPath: IndexPath) {
        cellController(at: indexPath).cancel()
    }
}
