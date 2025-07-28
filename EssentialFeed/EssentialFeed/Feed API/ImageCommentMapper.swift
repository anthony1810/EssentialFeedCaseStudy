//
//  ImageCommentMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 28/7/25.
//

import Foundation

enum ImageCommentMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    static func map(_ data: Data, res: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard isOkayResponse(res),
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        
        return root.items
    }
    
    static func isOkayResponse(_ res: HTTPURLResponse) -> Bool {
        (200...299).contains(res.statusCode)
    }
}
