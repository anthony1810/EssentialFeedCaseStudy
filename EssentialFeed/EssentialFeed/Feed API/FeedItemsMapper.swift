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
        var feedItems: [FeedItem] {
            items.map {  FeedItem(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                imageURL: $0.image)
            }
        }
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
        
       
    }
    
    static func map(_ res: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        guard res.statusCode == OK_200_STATUS,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
       
        let feedItems = root.feedItems
        return .success(feedItems)
    }
}
 
