//
//  WeakRefVirtualProxy.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import UIKit
import EssentialFeed
import EssentialFeediOS

class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(object: T ) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ viewModel: ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}

