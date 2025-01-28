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
        store.deleteCachedFeed(completion: { [weak self] error in
            guard let self else { return }
            
            if let error {
                completion(error)
            } else {
                self.store.insertCachedFeed(items, timestamp: self.currentDate(), completion: { [weak self] error in
                    guard self != nil else { return }
                    completion(error)
                })
            }
        })
    }
}
