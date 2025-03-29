//
//  FeedLoadingView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation

public struct LoadingViewModel {
    public var isLoading: Bool
}

public protocol FeedLoadingView {
    func display(viewModel: LoadingViewModel)
}
