//
//  FeedCommentItemsMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 2/12/24.
//

import Foundation

public final class FeedCommentItemsMapper {
    
    enum Error: Swift.Error {
        case invalidData
    }
    
    private struct Root: Decodable {
        private let items: [RemoteFeedComment]
        
        private struct RemoteFeedComment: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        private struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map { ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, author: $0.author.username)}
        }
    }
    
    public static func map(_ res: HTTPURLResponse, data: Data) throws -> [ImageComment] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard isOkay(res) else {
            throw Error.invalidData
        }
        
        do {
            let root = try decoder.decode(Root.self, from: data)
           
            return root.comments
        } catch {
            throw error
        }
    }
    
    static func isOkay(_ res: HTTPURLResponse) -> Bool {
        200...299 ~= res.statusCode
    }
}
 
