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
    private let calendar = Calendar(identifier: .gregorian)
    
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
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case let .success(items, timestamp) where self.validateTimestampt(timestamp) :
                completion(.success(items.toFeed()))
            case .success:
                completion(.success([]))
            default:
                completion(.success([]))
            }
        })
    }
    
    public func validateCache() {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCache(completion: { _ in })
            default:
                break
            }
        })
       
    }
    
    private func validateTimestampt(_ timestamp: Date) -> Bool {
        let maxCacheAge = calendar.date(byAdding: .day, value: -maxCacheDays, to: self.timestamp())!

        return timestamp <= maxCacheAge
    }
    
    private var maxCacheDays: Int {
        7
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
