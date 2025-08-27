//
//  Paginated.swift
//  EssentialFeed
//
//  Created by Anthony on 27/8/25.
//

import Foundation

public struct Paginated<Item> {
    public let items: [Item]
    public var loadMore: (() -> Result<Paginated<Item>, Error>)?
    
    public init(items: [Item], loadMore: (() -> Result<Paginated<Item>, Error>)? = nil) {
        self.items = items
        self.loadMore = loadMore
    }
}
