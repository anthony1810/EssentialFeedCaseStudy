//
//  FeedLoadingViewProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//
import Foundation

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
    
    static var isLoading: ResourceLoadingViewModel {
        return ResourceLoadingViewModel(isLoading: true)
    }
    
    static var noLoading: ResourceLoadingViewModel {
        return ResourceLoadingViewModel(isLoading: false)
    }
}

public protocol ResourceLoadingViewProtocol {
    func display(_ viewModel: ResourceLoadingViewModel)
}
