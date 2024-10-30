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

extension FeedViewController {
    func triggerViewDidLoad() {
        self.loadViewIfNeeded()
    }
    
    func triggerViewWillAppear() {
        self.beginAppearanceTransition(true, animated: false) //view appear again
        self.endAppearanceTransition()
    }
    
    @discardableResult
    func stimulateVisibleView(at index: Int) -> UITableViewCell {
        let cell = feedImageView(at: index)
        return cell ?? UITableViewCell()
    }
    
    func stimulateViewDisappear(at index: Int, file: StaticString = #file, line: UInt = #line) {
        let cell = stimulateVisibleView(at: index)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfRows(inSection: feedImageSection)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
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
    
    func stimulateBecomeNotVisibleView(at index: Int) {
        stimulateVisibleView(at: index)
        
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
}

public extension FeedViewController {
    func userInitiatedRefresh() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        self.refreshControl?.isRefreshing ?? false
    }
}
