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
        guard res.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteImageCommentLoader.Error.invalidData
        }
        
        return root.items
    }
}
