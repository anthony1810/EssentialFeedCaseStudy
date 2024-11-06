//
//  FeedErrorViewProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}

public protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}
