import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
   
    public var didRequestFeedRefresh: (() -> Void)?
    public private(set) var errorView = ErrorView()
    
    private var onViewIsAppearing: ((ListViewController) -> Void)?
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { tableView, indexPath, controller -> UITableViewCell? in
            controller.ds.tableView(tableView, cellForRowAt: indexPath)
        }
    }()
    
    public override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        if previous?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            tableView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
        configureErrorView()
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refresh()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    private func configureErrorView() {
        tableView.tableHeaderView = errorView.makeContainer()
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
    }
    
    public func display(_ tableModel: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(tableModel, toSection: 0)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
    public func display(viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
        self.tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        didRequestFeedRefresh?()
    }
    
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("forRowAt \(indexPath)")
        let cellController = cellController(forRowAt: indexPath)
        cellController?.dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = self.cellController(forRowAt: indexPath)
            cellController?.dsPrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = self.cellController(forRowAt: indexPath)
            cellController?.dsPrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath)?.dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController? {
        let cell = dataSource.itemIdentifier(for: indexPath)
        return cell
    }
}
