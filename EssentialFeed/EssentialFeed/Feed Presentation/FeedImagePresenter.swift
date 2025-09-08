//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 30/3/25.
//
import Foundation

public final class FeedImagePresenter {
    public static func map(_ feed: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            location: feed.location,
            description: feed.description
        )
    }
}
