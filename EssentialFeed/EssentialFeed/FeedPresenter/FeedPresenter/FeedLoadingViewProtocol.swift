//
//  FeedLoadingViewProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//
import Foundation

public struct FeedLoadingViewModel {
    public let isLoading: Bool
    
    static var isLoading: FeedLoadingViewModel {
        return FeedLoadingViewModel(isLoading: true)
    }
    
    static var noLoading: FeedLoadingViewModel {
        return FeedLoadingViewModel(isLoading: false)
    }
}

public protocol FeedLoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel)
}
