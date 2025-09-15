//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 2/2/25.
//

import XCTest
import EssentialFeed

final class FeedStoreSpy: FeedStore {
    struct InsertionMessage {
        let items: [LocalFeedImage]
        let timestamp: Date
    }
    
    enum ReceivedMessage: Equatable {
        case deletion
        case insertion([LocalFeedImage], Date)
        case retrieval
    }
    
    var deletionCompletions: Result<Void, Error>?
    var insertionCompletions: Result<Void, Error>?
    var retrievalCompletions: Swift.Result<CacheFeed?, Error>?
    
    var receivedMessages: [ReceivedMessage] = []
    
    func deleteCachedFeed() throws {
        receivedMessages.append(.deletion)
        try deletionCompletions?.get()
    }
    
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insertion(items, timestamp))
        try insertionCompletions?.get()
    }
    
    func retrievalCachedFeed() throws -> CacheFeed? {
        receivedMessages.append(.retrieval)
        return try retrievalCompletions?.get()
    }
    
    func completeDeletion(with result: Result<Void, Error>, at index: Int = 0) {
        deletionCompletions = result
    }
    
    func completionInsertion(with result: Result<Void, Error>, at index: Int = 0) {
        insertionCompletions = result
    }
    
    func completionRetrieval(with result: Swift.Result<FeedStore.CacheFeed?, Error>, at index: Int = 0) {
        retrievalCompletions = result
    }
}
