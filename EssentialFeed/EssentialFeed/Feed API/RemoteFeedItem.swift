//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
    
    var feed: FeedItem {
        FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}
