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
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter, refreshController: UIRefreshControl) {
        self.presenter = presenter
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
        presenter.loadFeeds()
    }
}
