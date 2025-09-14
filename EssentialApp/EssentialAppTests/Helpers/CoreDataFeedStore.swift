//
//  CoreDataFeedStore.swift
//  EssentialApp
//
//  Created by Anthony on 25/7/25.
//
import Foundation
import EssentialFeed

extension CoreDataFeedStore {
    static var empty: CoreDataFeedStore {
        get throws {
            try CoreDataFeedStore(storeURL: URL(filePath: "/dev/null"), contextQueue: .main)
        }
    }
    
    static var expiredCacheFeed: CoreDataFeedStore {
        get throws {
            let store = try CoreDataFeedStore(storeURL: URL(filePath: "/dev/null"), contextQueue: .main)
            try store.insertCachedFeed([], timestamp: Date.distantPast)
            return store
        }
    }
    
    static var nonExpiredCacheFeed: CoreDataFeedStore {
        get throws {
            let store = try CoreDataFeedStore(storeURL: URL(filePath: "/dev/null"), contextQueue: .main)
            try store.insertCachedFeed([], timestamp: Date())
            return store
        }
    }
}
