//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 6/12/24.
//

import Foundation

public final class FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(from response: HTTPURLResponse, data: Data) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
}
