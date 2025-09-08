//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 30/3/25.
//

public struct FeedImageViewModel {
    public var location: String?
    public var description: String?

    public var hasLocation: Bool {
        location != nil
    }
}
