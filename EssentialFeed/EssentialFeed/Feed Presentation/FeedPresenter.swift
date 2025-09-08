//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 29/3/25.
//
import Foundation

public final class FeedPresenter {
   
    public static var title: String {
        NSLocalizedString(
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    public static var loadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Load error for the feed view"
        )
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feeds: feed)
    }
}
