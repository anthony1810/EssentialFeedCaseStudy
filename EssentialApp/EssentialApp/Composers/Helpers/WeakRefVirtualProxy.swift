//
//  WeakRefVirtualProxy.swift
//  EssentialFeed
//
//  Created by Anthony on 2/11/24.
//
import Foundation
import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var target: T?
    
    init(target: T) {
        self.target = target
    }
}

extension WeakRefVirtualProxy: FeedLoadingViewProtocol where T: FeedLoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel) {
        target?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        target?.display(model)
    }
}

extension WeakRefVirtualProxy: LoadResourceErrorViewProtocol where T: LoadResourceErrorViewProtocol {
    func display(_ viewModel: LoadResourceErrorViewModel) {
        target?.display(viewModel)
    }
}
