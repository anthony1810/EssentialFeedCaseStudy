//
//  FeedRefreshController.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import UIKit

final class FeedRefreshController: NSObject, FeedLoadingViewProtocol {

    private(set) var view: UIRefreshControl
    private let loadFeed: () -> Void
    
    init(loadFeeds: @escaping () -> Void, refreshController: UIRefreshControl) {
        self.loadFeed = loadFeeds
        self.view = refreshController
        super.init()
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            self.view.beginRefreshing()
        } else {
            self.view.endRefreshing()
        }
    }
    
    @objc func refresh() {
        self.loadFeed()
    }
}
