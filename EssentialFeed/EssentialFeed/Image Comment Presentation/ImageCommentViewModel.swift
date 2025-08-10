//
//  ImageCommentViewModel.swift
//  EssentialFeed
//
//  Created by Anthony on 10/8/25.
//

public struct ImageCommentViewModel: Equatable {
    public var message: String
    public var date: String
    public var username: String
    
    public init(message: String, date: String, username: String) {
        self.message = message
        self.date = date
        self.username = username
    }
}
