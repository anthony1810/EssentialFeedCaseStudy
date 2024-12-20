//
//  FeedViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 26/10/24.
//
import Foundation
import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController {
    
    public var onRefresh: (() -> Void)?
    private(set) public var errorView = ErrorView()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, indexPath, cellController in
            return cellController.datasource.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    private var onViewFirstAppear: (() -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        dataSource.defaultRowAnimation = .fade
        
        configureErrorView()
        
        onViewFirstAppear = { [weak self] in
            self?.loadFeeds()
            self?.onViewFirstAppear = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewFirstAppear?()
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .backgroundErrorColor
        container.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: errorView.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            container.bottomAnchor.constraint(equalTo: errorView.bottomAnchor),
        ])
        
        tableView.tableHeaderView = container
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
//            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    @objc
    @IBAction private func refresh() {
        onRefresh?()
    }
}

// MARK: - FeedLoadingViewProtocol
extension ListViewController: ResourceLoadingViewProtocol {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            self.refreshControl?.beginRefreshing()
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers, toSection: 0)
        dataSource.apply(snapshot)
    }
}

// MARK: - FeedErrorViewProtocol
extension ListViewController: LoadResourceErrorViewProtocol {
    public func display(_ viewModel: LoadResourceErrorViewModel) {
        if let message = viewModel.message {
            errorView.show(message: message)
        } else {
            errorView.hideMessageAnimation()
        }
    }
}


// MARK: - UITableViewDatasource
extension ListViewController {
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dl = cellController(at: indexPath)?.prefetching
        dl?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension ListViewController: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(at: indexPath)?.prefetching
            controller?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let controller = cellController(at: indexPath)?.prefetching
            controller?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
}

// MARK: - Helpers
extension ListViewController {
    @discardableResult
    func cellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
    
    @objc
    public func loadFeeds() {
        refresh()
    }
}
