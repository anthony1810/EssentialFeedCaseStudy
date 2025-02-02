//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Anthony on 28/1/25.
//
import Foundation

public final class LocalFeedLoader {
    let store: FeedStore
    let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed(completion: { [weak self] deletionError in
            guard let self else { return }
            
            if let deletionError {
                completion(deletionError)
            } else {
                self.cacheFeeds(items, completion: completion)
            }
        })
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrievalCachedFeed { [currentDate] result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .found(feeds, timestamp) where FeedCachePolicy.isCacheValidated(with: timestamp, against: currentDate()):
                completion(.success(feeds.toModel()))
            case .empty, .found:
                completion(.success([]))
            }
        }
    }
    
    private func cacheFeeds(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insertCachedFeed(items.toLocal(), timestamp: self.currentDate()) { [weak self] insertionError in
            guard self != nil else { return }
            completion(insertionError)
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

struct FeedCachePolicy {
    static var currentCalendar: Calendar = Calendar(identifier: .gregorian)
    static var maxCacheDays: Int { 7 }
    
    static func isCacheValidated(with timestamp: Date, against currentTimestamp: Date) -> Bool {
        guard let maxCacheAge = currentCalendar.date(byAdding: .day, value: maxCacheDays, to: timestamp)
        else { return false }
        
        return currentTimestamp < maxCacheAge
    }
}
