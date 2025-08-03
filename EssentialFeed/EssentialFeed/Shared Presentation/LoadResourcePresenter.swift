//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 2/8/25.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    private let loadingView: ResourceLoadingView
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let mapper: Mapper
    
    public static var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: Self.self),
            comment: "Load error for the resource view"
        )
    }
    
    public init(
        loadingView: ResourceLoadingView,
        resourceView: View,
        errorView: ResourceErrorView,
        mapper: @escaping Mapper
    ) {
        self.loadingView = loadingView
        self.resourceView = resourceView
        self.errorView = errorView
        self.mapper = mapper
    }
    
    public func didStartLoading() {
        self.errorView.display(.noError)
        self.loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with error: Error) {
        self.errorView.display(.error(message: Self.loadError))
        self.loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
    
    public func display(resource: Resource) {
        do {
            self.loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
            self.resourceView.display(try mapper(resource))
        } catch {
            self.didFinishLoading(with: error)
        }
    }
}
