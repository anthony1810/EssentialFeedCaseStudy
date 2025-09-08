//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Anthony on 25/8/25.
//

import Foundation

public enum FeedEndpoint {
    case get(after: UUID? = nil)
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(afterImageId):
            let url = baseURL
                .appendingPathComponent("v1")
                .appendingPathComponent("feed")
            
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                fatalError("Unable to create URLComponents from URL: \(url)")
            }
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            
            if let afterImageId {
                components.queryItems?.append(
                    URLQueryItem(name: "after_id", value: afterImageId.uuidString)
                )
            }
            
            return components.url!
        }
    }
}
