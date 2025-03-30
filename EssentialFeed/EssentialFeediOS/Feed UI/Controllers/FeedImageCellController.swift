import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellController: FeedImageView {
   
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
   
    init (delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell: FeedImageCell? = tableView.dequeueReusableCell()
        self.cell = cell
        delegate.didRequestImage()
        return cell!
    }

    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(viewModel: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.feedImageView?.setImageAnimated(viewModel.image)
        cell?.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImageContainer.isShimmering = viewModel.isLoading
    }
    
    private func releaseCellForReuse() {
        cell = nil
    }
}


