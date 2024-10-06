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

    public struct RemoteFeedItem: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        public init(id: UUID, description: String?, location: String?, imageURL: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.image = imageURL
        }
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ res: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard res.statusCode == OK_200_STATUS else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }

}
 
