//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
    
    init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = imageURL
    }
}
