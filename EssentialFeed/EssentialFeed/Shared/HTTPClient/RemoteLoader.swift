//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 4/12/24.
//

import Foundation

public final class RemoteLoader<Resource> {
    let httpClient: HTTPClient
    let url: URL
    let mapper: Mapper
    
    public typealias Result = Swift.Result<Resource, Error>
    public typealias Mapper = (HTTPURLResponse, Data) throws -> Resource
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(httpClient: HTTPClient, url: URL, mapper: @escaping Mapper) {
        self.httpClient = httpClient
        self.url = url
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
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
    
    func toRemoteFeedItemResult(from res: HTTPURLResponse, data: Data) -> Result {
        do {
            let result = try self.mapper(res, data)
            return .success(result)
        } catch {
            return .failure(.invalidData)
        }
    }
}
