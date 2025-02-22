//
//  FeedViewController+Test.swift
//  EssentialFeed
//
//  Created by Anthony on 20/2/25.
//
import UIKit
import EssentialFeediOS

extension FeedViewController {
    func simulateFeedImageViewVisible(at index: Int) {
        _ = feedImageView(at: index)
    }

    func feedImageView(at index: Int) -> FeedImageCell? {
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.dataSource
        let cell = ds?.tableView(tableView, cellForRowAt: indexPath) as? FeedImageCell
        
        return cell
    }
    
    func numberOfRenderedFeeds() -> Int {
        tableView.numberOfRows(inSection: feedSection)
    }
    
    var feedSection: Int {
        0
    }
    
    func isLoadingIndicatorVisible() -> Bool {
        refreshControl?.isRefreshing == true
    }
    
    func userInitiateFeedReload() {
        simulatePullToRefresh()
    }
    
    func simulatePullToRefresh() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
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
    
    private class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false
        
        override var isRefreshing: Bool { _isRefreshing }
        
        override func beginRefreshing() {
            _isRefreshing = true
        }
        
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
}
