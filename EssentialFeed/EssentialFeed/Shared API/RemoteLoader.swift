//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 29/7/25.
//
import Foundation

public final class RemoteLoader: FeedLoader {
    
    public typealias Result = FeedLoader.Result
    
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
                completion(Self.map(data: data, res: res))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private static func map(data: Data, res: HTTPURLResponse) -> Result {
        do {
            let items = try FeedMapper.map(data, res: res)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

