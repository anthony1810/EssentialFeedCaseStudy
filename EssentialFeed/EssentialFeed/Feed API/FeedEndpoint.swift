//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Anthony on 25/8/25.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            var component = URLComponents()
            component.scheme = baseURL.scheme
            component.host = baseURL.host
            component.path = baseURL.path() + "/v1/feed"
            component.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            return component.url!
        }
    }
}
