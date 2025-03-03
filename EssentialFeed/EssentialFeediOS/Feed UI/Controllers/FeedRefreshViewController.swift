//
//  FeedRefreshViewController.swift
//  EssentialFeed
//
//  Created by Anthony on 25/2/25.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    public lazy var view: UIRefreshControl = binded(to: UIRefreshControl())
    
    private let viewModel: FeedRefreshViewModel
    
    public init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    @objc
    func refresh() {
        viewModel.loadFeed()
    }
    
    func binded(to refreshControl: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChanged = { [weak self] viewModel in
            if viewModel.isLoading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }
}
