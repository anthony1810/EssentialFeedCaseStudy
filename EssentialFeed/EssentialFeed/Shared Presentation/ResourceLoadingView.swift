//
//  FeedLoadingView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation

public struct ResourceLoadingViewModel {
    public var isLoading: Bool
}

public protocol ResourceLoadingView {
    func display(viewModel: ResourceLoadingViewModel)
}
