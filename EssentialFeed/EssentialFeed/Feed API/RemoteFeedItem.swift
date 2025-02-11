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
}
