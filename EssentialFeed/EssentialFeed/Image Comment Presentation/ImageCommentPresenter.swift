//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

import Foundation

public final class ImageCommentPresenter {
    public static func map(_ feed: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            location: feed.location,
            description: feed.description
        )
    }
}
