//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 6/10/24.
//
import Foundation

internal final class FeedItemsMapper {
    
    private static var OK_200_STATUS = 200
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ res: HTTPURLResponse, data: Data) throws -> [RemoteFeedItem] {
        guard res.statusCode == OK_200_STATUS, let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteFeedLoader.Error.invalidData
        }
       
        return root.items
    }
}
 
