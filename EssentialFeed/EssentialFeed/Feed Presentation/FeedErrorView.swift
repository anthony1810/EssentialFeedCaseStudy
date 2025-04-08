//
//  FeedErrorView.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: Self {
        FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}
