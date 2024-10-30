//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import UIKit

final class FeedRefreshController: NSObject {
    
    private(set) var view: UIRefreshControl
    private let viewModel: FeedRefreshViewModel
    
    init(viewModel: FeedRefreshViewModel, refreshController: UIRefreshControl) {
        self.viewModel = viewModel
        self.view = refreshController
        super.init()
        
        bind(to: view)
    }
    
    func bind(to view: UIRefreshControl) {
        viewModel.onChange = { [weak self] isLoading in
            if isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    @objc func refresh() {
        viewModel.loadFeeds()
    }
}
