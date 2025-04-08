//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 30/3/25.
//

public struct FeedImageViewModel<Image> {
    public var location: String?
    public var description: String?
    public var image: Image?
    public var isLoading: Bool
    public var shouldRetry: Bool

    public var hasLocation: Bool {
        location != nil
    }
}

public protocol FeedImageView {
    associatedtype Image
    func display(viewModel: FeedImageViewModel<Image>)
}
