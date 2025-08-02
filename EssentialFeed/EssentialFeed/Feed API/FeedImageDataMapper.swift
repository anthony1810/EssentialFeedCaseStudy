//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Anthony on 2/8/25.
//
import Foundation

public enum FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else {
            throw Error.invalidData
        }
        
        return data
    }
}
