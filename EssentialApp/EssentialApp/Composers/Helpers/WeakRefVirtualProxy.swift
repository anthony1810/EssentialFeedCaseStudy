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

extension WeakRefVirtualProxy: ResourceLoadingViewProtocol where T: ResourceLoadingViewProtocol {
    func display(_ viewModel: ResourceLoadingViewModel) {
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

extension WeakRefVirtualProxy: ResourceFetchingViewProtocol where T: ResourceFetchingViewProtocol, T.ViewModel == UIImage {
    typealias ViewModel = UIImage
    
    func display(viewModel: UIImage) {
        target?.display(viewModel: viewModel)
    }
}
