//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit
import EssentialFeed

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
    func prefetch()
    func cancelLoading()
}

public final class ListViewController: UITableViewController {
    
    public var onRefresh: (() -> Void)?
    @IBOutlet private(set) public var errorView: ErrorView!
    
    public var tableModels: [CellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    private var onViewFirstAppear: (() -> Void)?
    private var loadingCells = [IndexPath: CellController]()
    
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
        onRefresh?()
    }
}

// MARK: - FeedLoadingViewProtocol
extension ListViewController: ResourceLoadingViewProtocol {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        loadingCells.removeAll()
        if viewModel.isLoading {
            self.refreshControl?.beginRefreshing()
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - FeedErrorViewProtocol
extension ListViewController: LoadResourceErrorViewProtocol {
    public func display(_ viewModel: LoadResourceErrorViewModel) {
        if let message = viewModel.message {
            errorView.show(message: message)
        } else {
            errorView.hideMessage()
        }
    }
}


// MARK: - UITableViewDatasource
extension ListViewController {
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
extension ListViewController: UITableViewDataSourcePrefetching {
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
extension ListViewController {
    func cancelLoading(at indexPath: IndexPath) {
        loadingCells[indexPath]?.cancelLoading()
        loadingCells[indexPath] = nil
    }
    
    @discardableResult
    func cellController(at indexPath: IndexPath) -> CellController {
        let cellController = tableModels[indexPath.row]
        loadingCells[indexPath] = cellController
        return cellController
    }
    
    @objc
    public func loadFeeds() {
        refresh()
    }
}
