//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

final class RemoteFeedLoader {
    let httpClient: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (EssentialFeed.LoadFeedResult) -> Void) {
        httpClient.get(url: self.url, completion: { httpCompletion in
            switch httpCompletion {
            case .success:
                completion(.error(Self.Error.invalidData))
            case .failure:
                completion(.error(Self.Error.connectivity))
            }
        })
    }
}
