//
//  ImageComment.swift
//  EssentialFeed
//
//  Created by Anthony on 4/12/24.
//
import Foundation

public struct ImageComment: Equatable {
    let id: UUID
    let message: String
    let createdAt: Date
    let author: String
    
    public init(id: UUID, message: String, createdAt: Date, author: String) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }
}
