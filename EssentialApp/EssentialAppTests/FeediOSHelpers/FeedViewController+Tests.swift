//
//  FeedViewController+Tests.swift
//  EssentialFeed
//
//  Created by Anthony on 28/10/24.
//
import Foundation
import EssentialFeed
import EssentialFeediOS
import UIKit

extension ListViewController {
    func triggerViewDidLoad() {
        self.loadViewIfNeeded()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }
    
    func triggerViewWillAppear() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17PlusSupport()
        }
        
        self.beginAppearanceTransition(true, animated: false) //view appear again
        self.endAppearanceTransition()
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    var isShowingErrorView: Bool {
        return errorView.alpha == 1
    }

    var displayedErrorViewMessage: String? {
        return errorView.message
    }
    
    @discardableResult
    func stimulateVisibleView(at index: Int) -> FeedImageCell {
        let cell = feedImageView(at: index)
        return cell as! FeedImageCell
    }
    
    @discardableResult
    func stimulateViewDisappear(at index: Int, file: StaticString = #file, line: UInt = #line) -> FeedImageCell {
        let cell = stimulateVisibleView(at: index)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        return cell
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 :
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > index else { return nil }
        
        let ds = tableView.dataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        let view = ds?.tableView(tableView, cellForRowAt: indexPath)
        
        return view
    }
    
    var feedImageSection: Int { 0 }
    
    func stimulateNearVisibleView(at index: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    @discardableResult
    func stimulateBecomeNotVisibleView(at index: Int) -> FeedImageCell {
        let cell = stimulateVisibleView(at: index)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        
        return cell
    }
    
    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fakeRefreshControl
    }
}

public extension ListViewController {
    func userInitiatedRefresh() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        self.refreshControl?.isRefreshing ?? false
    }
}
