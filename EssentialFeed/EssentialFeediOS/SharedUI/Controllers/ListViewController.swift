//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit
import EssentialFeed

public struct CellController {
    let datasource: UITableViewDataSource
    let delegate: UITableViewDelegate?
    let prefetching: UITableViewDataSourcePrefetching?
    
    public init(datasource: UITableViewDataSource, delegate: UITableViewDelegate?, prefetching: UITableViewDataSourcePrefetching?) {
        self.datasource = datasource
        self.delegate = delegate
        self.prefetching = prefetching
    }
    
    public init(datasource: UITableViewDataSource) {
        self.datasource = datasource
        self.delegate = nil
        self.prefetching = nil
    }
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
        let ds = cellController(at: indexPath).datasource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = removeLoadingCellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath).prefetching
        dl?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension ListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(at: indexPath).prefetching
            controller?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = removeLoadingCellController(at: indexPath)?.prefetching
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
}

// MARK: - Helpers
extension ListViewController {
    func removeLoadingCellController(at indexPath: IndexPath) -> CellController? {
        let controller = cellController(at: indexPath)
        loadingCells[indexPath] = nil
        return controller
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
