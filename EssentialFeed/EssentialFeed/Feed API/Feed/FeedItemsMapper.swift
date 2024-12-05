//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation

public final class FeedItemsMapper {
    
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        var feeds: [FeedImage] {
            items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
            }
        }
    }
    
    public static func map(_ res: HTTPURLResponse, data: Data) throws -> [FeedImage] {
        guard res.isOK, let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
       
        return root.feeds
    }
}
