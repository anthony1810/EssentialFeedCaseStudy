//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//
import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    private let store: FeedStore
    private let timestamp: () -> Date
    
    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCache(completion: { [weak self] error in
            guard let self else { return }
            
            if let error {
                completion(error)
            } else {
                self.insertCache(items, timestamp: timestamp(), completion: completion)
            }
        })
    }
    
    func insertCache(_ items: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        self.store.insertCache(items.toLocal(), timestamp: timestamp, completion: { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        })
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: { result in
            switch result {
            case .success(let items, _):
                completion(.success(items.toFeed()))
            case .failure(let error):
                completion(.failure(error))
            case .empty:
                completion(.success([]))
            }
        })
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.imageURL) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toFeed() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
