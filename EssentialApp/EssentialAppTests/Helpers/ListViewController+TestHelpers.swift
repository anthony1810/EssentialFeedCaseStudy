import UIKit
import EssentialFeed
import EssentialFeediOS

extension ListViewController {
    func cell(for row: Int, section: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        let cell = ds?.tableView(tableView, cellForRowAt: index)
        
        return cell
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: section)
    }
}

extension ListViewController {
    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateLoadMoreFeed() {
        guard let view = cell(for: 0, section: loadMoreSection)
        else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        guard let view = simulateFeedImageViewVisible(at: row) else { return nil }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt: index)
        
        return view
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateFeedImageTap(at index: Int) {
        let dl = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSection)
        dl?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    private var loadMoreSection: Int {
        return 1
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        
        return cell(for: row, section: feedImageSection)
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    var isErrorViewVisible: Bool {
        errorView.isHidden == false
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeUIRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fakeRefreshControl
    }
}

extension ListViewController {
    private var commentSection: Int {
        return 0
    }
    
    func numberOfRenderedCommentsViews() -> Int {
        numberOfRows(in: commentSection)
    }
    
    func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedCommentsViews() > row else {
            return nil
        }
        
        let cell = cell(for: row, section: commentSection)
        
        return cell as? ImageCommentCell
    }
    
    func commentAuthor(at row: Int) -> String? {
        let view = commentView(at: row)
        return view?.authorLabel.text
    }
    
    func commentMessage(at row: Int) -> String? {
        let view = commentView(at: row)
        return view?.commentLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        let view = commentView(at: row)
        return view?.dateLabel.text
    }
}
