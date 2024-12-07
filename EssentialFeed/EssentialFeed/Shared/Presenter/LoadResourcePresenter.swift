//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 7/12/24.
//

import Foundation

public protocol ResourceFetchingViewProtocol {
    associatedtype ViewModel
    func display(viewModel: ViewModel)
}

public class LoadResourcePresenter<Resource, View: ResourceFetchingViewProtocol> {
    public typealias Mapper = (Resource) -> View.ViewModel
    
    private var loadingView: FeedLoadingViewProtocol
    private var errorView: LoadResourceErrorViewProtocol
    private var fetchingView: View
    
    private var mapper: Mapper
    
    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR", tableName: "Shared", bundle: Bundle(for: FeedPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public init(
        loadingView: FeedLoadingViewProtocol,
        errorView: LoadResourceErrorViewProtocol,
        fetchingView: View,
        mapper: @escaping Mapper
    ) {
        self.loadingView = loadingView
        self.errorView = errorView
        self.fetchingView = fetchingView
        self.mapper = mapper
    }
    
    public func startLoading() {
        loadingView.display(.isLoading)
        errorView.display(.noError)
    }
    
    public func finishLoadingSuccessfully(with resource: Resource) {
        fetchingView.display(viewModel: mapper(resource))
        loadingView.display(.noLoading)
    }
    
    public func finishLoadingFailure(error: Error) {
        loadingView.display(.noLoading)
        errorView.display(.error(message: Self.loadError))
    }
}
