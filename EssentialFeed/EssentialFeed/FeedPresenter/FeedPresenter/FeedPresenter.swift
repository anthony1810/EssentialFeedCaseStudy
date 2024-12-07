//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 6/11/24.
//

import Foundation

public class FeedPresenter {
    
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: FeedPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public static func map(_ feeds: [FeedImage]) -> FeedFetchingViewModel  {
        FeedFetchingViewModel(feeds: feeds)
    }
}
