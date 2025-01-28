//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 24/1/25.
//
import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    public typealias Result = LoadFeedResult
    
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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success((data, res)):
                completion(Self.Result { try FeedMapper.map(data, res: res).toModels() })
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
}

extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
