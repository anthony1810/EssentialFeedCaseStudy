//
//  ImageCommentPresenter.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

import Foundation

public final class ImageCommentPresenter {
    public static var title: String {
        NSLocalizedString(
            "IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComment",
            bundle: Bundle(for: Self.self),
            comment: "Title for ImageCommentView"
        )
    }
    
    public static func map(_ comments: [ImageComment]) -> ImageCommentsViewModel {
        let dateFormatter = RelativeDateTimeFormatter()
        
        let comments = comments.map {
            ImageCommentViewModel(
                message: $0.message,
                date: dateFormatter.localizedString(for: $0.createdAt, relativeTo: Date()),
                username: $0.username
            )
        }
        
        return ImageCommentsViewModel(comments: comments)
    }
}
