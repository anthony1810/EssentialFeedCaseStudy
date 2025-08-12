import UIKit
import EssentialFeed

public final class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView, ResourceErrorView {
   
    public var didRequestFeedRefresh: (() -> Void)?
    @IBOutlet public private(set) var errorView: ErrorView!
    
    private var onViewIsAppearing: ((ListViewController) -> Void)?
    var tableModel = [CellController]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refresh()
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        onViewIsAppearing?(self)
    }
    
    public func display(_ tableModel: [CellController]) {
        self.tableModel = tableModel
    }
    
    public func display(viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.setMessageAnimated(viewModel.message)
    }
    
    @IBAction private func refresh() {
        didRequestFeedRefresh?()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath).ds
        return cellController.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellController = removeCellControllerLoad(forRowAt: indexPath)
        cellController.dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = self.cellController(forRowAt: indexPath)
            cellController.dsPrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = self.removeCellControllerLoad(forRowAt: indexPath)
            cellController.dsPrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> CellController {
        return tableModel[indexPath.row]
    }
    
    private func removeCellControllerLoad(forRowAt indexPath: IndexPath) -> CellController {
        let cellController = tableModel[indexPath.row]
        tableModel.remove(at: indexPath.row)
        return cellController
    }
}
