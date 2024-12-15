//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 15/12/24.
//


import Foundation

public struct ImageCommentViewModels {
    public var comments: [ImageCommentViewModel]
}

public struct ImageCommentViewModel: Equatable {
    public let message: String
    public let date: String
    public let username: String

    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}

public class ImageCommentPresenter {
    
    public static var title: String {
        return NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE", tableName: "ImageComment", bundle: Bundle(for: ImageCommentPresenter.self),  comment: "Error Message displayed when there is an error loading the feed")
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentViewModels  {
        let formatter = RelativeDateTimeFormatter()
        return ImageCommentViewModels(comments:
            comments.map { comment in
            ImageCommentViewModel(
                message: comment.message,
                date: formatter.localizedString(for: comment.createdAt, relativeTo: Date()),
                username: comment.author
            )}
        )
    }
}
