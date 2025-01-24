//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 24/1/25.
//
import Foundation

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load() {
        client.get(from: url)
    }
}

public protocol HTTPClient {
    func get(from url: URL)
}
