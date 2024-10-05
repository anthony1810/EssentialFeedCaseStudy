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
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        httpClient.get(url: self.url, completion: { httpCompletion in
            switch httpCompletion {
            case .success(let res, let data):
                do {
                    let result = try FeedItemsMapper.map(res, data: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(Self.Error.invalidData))
                }
            case .failure:
                completion(.failure(Self.Error.connectivity))
            }
        })
    }
}

private class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    public struct RemoteFeedItem: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        public init(id: UUID, description: String?, location: String?, imageURL: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.image = imageURL
        }
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static func map(_ res: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        guard res.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }

}
 
