//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Anthony on 27/8/25.
//

import Foundation

public struct Paginated<Item> {
    public typealias LoadMoreCompletion = (Result<Paginated<Item>, Error>) -> Void
    
    public let items: [Item]
    public var loadMore: ((@escaping LoadMoreCompletion) -> Void)?
    
    public init(items: [Item], loadMore: ((@escaping LoadMoreCompletion) -> Void)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
