//
//  WeakRefVirtualProxy.swift
//  EssentialFeed
//
//  Created by Anthony on 17/3/25.
//
import UIKit

class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(object: T ) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: LoadingView where T: LoadingView {
    func display(viewModel: LoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(viewModel: FeedImageViewModel<UIImage>) {
        object?.display(viewModel: viewModel)
    }
}

