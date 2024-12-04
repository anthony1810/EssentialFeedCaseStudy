//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 5/10/24.
//
import Foundation

public final class RemoteFeedLoader: FeedLoaderProtocol {
    let httpClient: HTTPClient
    let url: URL
    
    typealias Result = FeedLoaderProtocol.Result
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (FeedLoaderProtocol.Result) -> Void) {
        httpClient.get(from: self.url, completion: { [weak self] httpCompletion in
            guard let self else { return }
            switch httpCompletion {
            case .success((let res, let data)):
                completion(self.toRemoteFeedItemResult(from: res, data: data))
            case .failure:
                completion(.failure(Self.Error.connectivity))
            }
        })
    }
    
    func toRemoteFeedItemResult(from res: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        do {
            let result = try FeedItemsMapper.map(res, data: data)
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
}
