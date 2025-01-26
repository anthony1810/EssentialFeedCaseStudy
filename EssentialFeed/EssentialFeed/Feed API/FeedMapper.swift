//
//  FeedMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 25/1/25.
//

import Foundation

enum FeedMapper {
    private static var OKAY_200: Int { 200 }
    private struct Root: Decodable {
        let items: [Item]
        
        var feeds: [FeedItem] {
            items.map(\.feed)
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feed: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static func map(_ data: Data, res: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard res.statusCode == OKAY_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feeds)
    }
}
