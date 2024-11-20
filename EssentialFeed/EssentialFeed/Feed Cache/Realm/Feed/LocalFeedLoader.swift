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
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(.found( items, timestamp)) where
                FeedCachePolicy.validate(timestamp, against: self.timestamp()):
                completion(.success(items.toFeed()))
            case .success:
                completion(.success([]))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}


extension LocalFeedLoader {
    public typealias ValidateResult = Result<Void, Error>
    
    public func validateCache(completion: @escaping (ValidateResult) -> Void = {_ in }) {
        store.retrieve(completion: { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                store.deleteCache(completion: { _ in completion(self.successValidation()) })
            case let .success(.found(_, timestamp))
                where !FeedCachePolicy.validate(timestamp, against: self.timestamp()):
                store.deleteCache(completion: { _ in completion(self.successValidation()) })
            case .success:
                completion(self.successValidation())
            }
        })
    }
    
    private func successValidation() -> ValidateResult {
        .success(())
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
