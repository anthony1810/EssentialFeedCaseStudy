import UIKit
public protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshViewController: NSObject, LoadingView {
    @IBOutlet public var view: UIRefreshControl?
    
    public var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(viewModel: LoadingViewModel) {
        if viewModel.isLoading {
            self.view?.beginRefreshing()
        } else {
            self.view?.endRefreshing()
        }
    }
}
