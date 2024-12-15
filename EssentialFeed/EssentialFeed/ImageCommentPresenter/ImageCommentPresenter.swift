//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 15/12/24.
//


import Foundation

public class ImageCommentPresenter {
    
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE", tableName: "ImageComment", bundle: Bundle(for: ImageCommentPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public static func map(_ feeds: [FeedImage]) -> FeedFetchingViewModel  {
        FeedFetchingViewModel(feeds: feeds)
    }
}
