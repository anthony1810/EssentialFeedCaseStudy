//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

public final class RemoteFeedLoader: FeedLoader {
    let httpClient: HTTPClient
    let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(from: self.url, completion: { [weak self] httpCompletion in
            guard self != nil else { return }
            switch httpCompletion {
            case .success(let res, let data):
                completion(FeedItemsMapper.map(res, data: data))
            case .failure:
                completion(.failure(Self.Error.connectivity))
            }
        })
    }
}

