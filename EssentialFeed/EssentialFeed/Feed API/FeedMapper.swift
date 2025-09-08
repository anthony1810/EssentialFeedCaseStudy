//
//  FeedMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 25/1/25.
//

import Foundation

public enum FeedMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
        
        struct RemoteFeedItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map {
                FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
            }
        }
    }
    
    enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, res: HTTPURLResponse) throws -> [FeedImage] {
        guard res.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw FeedMapper.Error.invalidData
        }
        
        return root.images
    }
}
