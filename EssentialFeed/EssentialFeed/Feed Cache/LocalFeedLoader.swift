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
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed(completion: { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success:
                self.store.insertCachedFeed(items, timestamp: self.currentDate()) { result in
                    if case let .failure(error) = result {
                        return completion(error)
                    }
                    return completion(nil)
                }
            case .failure(let error):
                completion(error)
            }
        })
    }
}
