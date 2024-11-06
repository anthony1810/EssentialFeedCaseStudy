//
//  FeedFetchingViewProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation

public struct FeedFetchingViewModel {
    public let feeds: [FeedImage]
}

public protocol FeedFetchingViewProtocol {
    func display(viewModel: FeedFetchingViewModel)
}
