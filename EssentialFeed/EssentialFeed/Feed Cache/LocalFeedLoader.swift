//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//
import Foundation

public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStoreProtocol
    private let timestamp: () -> Date
    
    public init(store: FeedStoreProtocol, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
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
    
    private func insertCache(_ items: [FeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        self.store.insertCache(items.toLocal(), timestamp: timestamp, completion: { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        })
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .success(items, timestamp) where
                FeedCachePolicy.validate(timestamp, against: self.timestamp()):
                completion(.success(items.toFeed()))
            case .empty, .success:
                completion(.success([]))
            }
        })
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCache(completion: { _ in })
            case let .success(_, timestamp) where !FeedCachePolicy.validate(timestamp, against: self.timestamp()) :
                store.deleteCache(completion: { _ in })
            case .empty, .success:
                break
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
