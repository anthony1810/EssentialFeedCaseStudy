//
//  FeedRefreshController.swift
//  EssentialFeed
//
//  Created by Anthony on 30/10/24.
//
import Foundation
import UIKit

public protocol FeedRefreshControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedRefreshController: NSObject, FeedLoadingViewProtocol {

    @IBOutlet public var view: UIRefreshControl!
    var delegate: FeedRefreshControllerDelegate?
    
   func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            self.view.beginRefreshing()
        } else {
            self.view.endRefreshing()
        }
    }
    
    @objc
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
}
