//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeed
//
//  Created by Anthony on 2/11/24.
//
import Foundation
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedRefreshDelegate {
    private let loader: FeedLoaderProtocol
    var presenter: LoadResourcePresenter<[FeedImage], FeedFetchView>?
    
    init(loader: FeedLoaderProtocol) {
        self.loader = loader
    }
    
    func didRequestFeedRefresh() {
        presenter?.startLoading()
        loader.load { [weak self] result in
            switch result {
            case .success(let feeds):
                self?.presenter?.finishLoadingSuccessfully(with: feeds)
            case .failure(let error):
                self?.presenter?.finishLoadingFailure(error: error)
            }
        }
    }
}


