//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

final class RemoteFeedLoader: FeedLoader {
    let httpClient: HTTPClient
    let url: URL
    
    public init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (EssentialFeed.LoadFeedResult) -> Void) {
        httpClient.get(url: self.url)
    }
}
