//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit

public final class ErrorView: UIView {
     public var message: String?
 }

public protocol FeedRefreshDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController {
    
    var delegate: FeedRefreshDelegate?
    public let errorView = ErrorView()
    
    var tableModels: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }

    private var onViewFirstAppear: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewFirstAppear = { [weak self] in
            self?.loadFeeds()
            self?.onViewFirstAppear = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewFirstAppear?()
    }
    
    @objc
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}

// MARK: - FeedLoadingViewProtocol
extension FeedViewController: FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel) {
         if viewModel.isLoading {
             self.refreshControl?.beginRefreshing()
         } else {
             self.refreshControl?.endRefreshing()
         }
     }
}

// MARK: - FeedErrorViewProtocol
extension FeedViewController: FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel) {
        errorView.message = viewModel.message
    }
}


// MARK: - UITableViewDatasource
extension FeedViewController {
    public override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModels.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellController(at: indexPath).view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
      
        cancelLoading(at: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).prefetch()
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension FeedViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(at: indexPath).prefetch()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelLoading(at:))
    }
}

// MARK: - Helpers
extension FeedViewController {
    func cancelLoading(at indexPath: IndexPath) {
        cellController(at: indexPath).cancelLoading()
    }
    
    @discardableResult
    func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        tableModels[indexPath.row]
    }
    
    @objc
    public func loadFeeds() {
        refresh()
    }
}
