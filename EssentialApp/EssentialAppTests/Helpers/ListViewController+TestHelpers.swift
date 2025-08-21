import UIKit
import EssentialFeed
import EssentialFeediOS

extension ListViewController {
    var isShowingLoadingIndicator: Bool {
        print("-> refreshControl (\(refreshControl.debugDescription) \(String(describing: refreshControl?.isRefreshing))")
        return refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
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
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else {
            return nil
        }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
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
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentSection)
    }
    
    func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedCommentsViews() > row else {
            return nil
        }
        
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentSection)
        let cell = ds?.tableView(tableView, cellForRowAt: index)
        
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
