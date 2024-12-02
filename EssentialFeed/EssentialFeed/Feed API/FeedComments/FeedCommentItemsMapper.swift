//
//  FeedCommentItemsMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 2/12/24.
//

import Foundation

internal final class FeedCommentItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ res: HTTPURLResponse, data: Data) throws -> [RemoteFeedItem] {
        guard isOkay(res), let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }
       
        return root.items
    }
    
    static func isOkay(_ res: HTTPURLResponse) -> Bool {
        200...299 ~= res.statusCode
    }
}
 
