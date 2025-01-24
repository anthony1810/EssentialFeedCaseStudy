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
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Error?) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        })
    }
}

public protocol HTTPClient {
    typealias LoadResult = Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (LoadResult) -> Void)
}
