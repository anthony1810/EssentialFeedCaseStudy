//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by Anthony on 25/8/25.
//
import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(feedImageID):
            return baseURL.appendingPathComponent("v1/image/\(feedImageID)/comments")
        }
    }
}
