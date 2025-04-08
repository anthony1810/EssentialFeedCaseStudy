//
//  FeedView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation

public struct FeedViewModel {
    public var feeds: [FeedImage]
}

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}
