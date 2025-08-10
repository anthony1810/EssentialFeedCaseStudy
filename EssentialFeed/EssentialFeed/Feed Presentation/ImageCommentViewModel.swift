//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

public struct ImageCommentViewModel {
    public var location: String?
    public var description: String?

    public var hasLocation: Bool {
        location != nil
    }
}
