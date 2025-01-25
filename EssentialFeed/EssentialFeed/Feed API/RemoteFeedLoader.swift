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
        client.get(from: url, completion: { result in
            switch result {
            case let .success((data, res)):
                guard res.statusCode == 200 else {
                    return completion(.failure(.invalidData))
                }
                
                do {
                    let root = try JSONDecoder().decode(Root.self, from: data)
                    completion(.success(root.items.map(\.feed)))
                } catch {
                    return completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        })
    }
}

private struct Root: Decodable {
    let items: [Item]
}

private struct Item: Decodable {
    let id: UUID
    let description: String
    let location: String
    let image: URL
    
    var feed: FeedItem {
        FeedItem(id: id, description: description, location: location, imageURL: image)
    }
}

public protocol HTTPClient {
    typealias LoadResult = Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (LoadResult) -> Void)
}
