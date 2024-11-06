//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//
import Foundation

public struct FeedImageViewModel<Image> {
    public let location: String?
    public let description: String?
    public let url: URL
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
}


public protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}
