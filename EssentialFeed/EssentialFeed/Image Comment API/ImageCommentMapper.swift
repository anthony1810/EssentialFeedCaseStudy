//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 28/7/25.
//

import Foundation

enum ImageCommentMapper {
    private struct Root: Decodable {
        private let items: [RemoteImageComment]
        
        private struct RemoteImageComment: Decodable {
            let id: UUID
            let message: String
            let created_at: Date
            let author: Author
        }
        
        struct Author: Decodable {
            let username: String
        }
        
        var comments: [ImageComment] {
            items.map {
                ImageComment(id: $0.id, message: $0.message, createdAt: $0.created_at, username: $0.author.username)
            }
        }
    }

    static func map(_ data: Data, res: HTTPURLResponse) throws -> [ImageComment] {
        guard isOkayResponse(res) else {
            throw RemoteImageCommentLoader.Error.connectivity
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let root = try decoder.decode(Root.self, from: data)
            return root.comments
        } catch {
            print(error)
            throw RemoteImageCommentLoader.Error.invalidData
        }
    }
    
    static func isOkayResponse(_ res: HTTPURLResponse) -> Bool {
        (200...299).contains(res.statusCode)
    }
}
