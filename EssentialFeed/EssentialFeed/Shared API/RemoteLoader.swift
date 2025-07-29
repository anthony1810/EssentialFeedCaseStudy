//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 29/7/25.
//
import Foundation

public final class RemoteLoader<T> {
    
    public typealias Result = Swift.Result<T, Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> T
    
    let url: URL
    let client: HTTPClient
    let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success((data, res)):
                completion(map(data: data, res: res))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        })
    }
    
    private func map(data: Data, res: HTTPURLResponse) -> Result {
        do {
            let items = try mapper(data, res)
            return .success(items)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

