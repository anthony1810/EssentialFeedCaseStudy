//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public final class LocalFeedLoader: FeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = FeedLoader.Result
    public typealias ValidationResult = Swift.Result<Void, Error>
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed(completion: { [weak self] deletionResult in
            guard let self else { return }
            
            switch deletionResult {
            case .success:
                self.cacheFeeds(items, completion: completion)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrievalCachedFeed { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(.some((let feeds, let timestamp))) where FeedCachePolicy.isCacheValidated(with: timestamp, against: currentDate()):
                completion(.success(feeds.toModel()))
            case .success(.none), .success:
                completion(.success([]))
            }
        }
    }
    
    public func validate(completion: @escaping (ValidationResult) -> Void) {
        store.retrievalCachedFeed { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCachedFeed(completion: { _ in completion(.success(())) })
            case .success(.some((_, let timestamp))) where FeedCachePolicy.isCacheValidated(with: timestamp, against: currentDate()) == false:
                store.deleteCachedFeed(completion: { _ in completion(.success(()))})
            case .success(.none), .success:
                completion(.success(()))
            }
        }
    }
    
    private func cacheFeeds(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCachedFeed(items.toLocal(), timestamp: self.currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }
            switch insertionResult {
            case .success:
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}

extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
