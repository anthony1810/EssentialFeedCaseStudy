//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 24/1/25.
//
import Foundation

public final class RemoteFeedLoader {
    
    public typealias Result = Swift.Result<[FeedItem], Error>
    
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (RemoteFeedLoader.Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, res)):
                completion(FeedMapper.map(data, res: res))
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

