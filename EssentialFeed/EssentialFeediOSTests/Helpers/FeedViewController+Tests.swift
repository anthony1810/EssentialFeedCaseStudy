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
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({ action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            })
        }
        
        refreshControl = fake
    }
    
    func triggerViewDidLoad() {
        self.loadViewIfNeeded()
    }
    
    func triggerViewWillAppear() {
        self.beginAppearanceTransition(true, animated: false) //view appear again
        self.endAppearanceTransition()
    }
    
    func stimulateVisibleView(at index: Int) {
        _ = feedImageView(at: index)
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
}

public extension FeedViewController {
    func userInitiatedRefresh() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    func isShowingLoadingIndicator() -> Bool {
        self.refreshControl?.isRefreshing ?? false
    }
}
