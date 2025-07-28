//
//  FeedMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 25/1/25.
//

import Foundation

enum FeedMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, res: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard res.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
