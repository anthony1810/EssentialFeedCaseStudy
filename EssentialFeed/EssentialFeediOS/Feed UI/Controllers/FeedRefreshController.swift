//
//  FeedRefreshController.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import UIKit

protocol FeedRefreshControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshController: NSObject, FeedLoadingViewProtocol {

    private(set) var view: UIRefreshControl
    private let delegate: FeedRefreshControllerDelegate
    
    init(delegate: FeedRefreshControllerDelegate, refreshController: UIRefreshControl) {
        self.delegate = delegate
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
        delegate.didRequestFeedRefresh()
    }
}
