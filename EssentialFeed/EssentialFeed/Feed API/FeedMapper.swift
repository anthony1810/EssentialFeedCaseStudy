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
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, res: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard res.statusCode == OKAY_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
