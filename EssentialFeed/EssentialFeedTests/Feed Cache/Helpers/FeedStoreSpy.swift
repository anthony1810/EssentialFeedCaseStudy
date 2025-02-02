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
    
    var deletionCompletions = [DeletionCompletion]()
    var insertionCompletions = [InsertionCompletion]()
    var retrievalCompletions = [RetrievalCompletion]()
    
    var receivedMessages: [ReceivedMessage] = []
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletion)
    }
    
    func insertCachedFeed(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insertion(items, timestamp))
    }
    
    func retrievalCachedFeed(completion: @escaping RetrievalCompletion) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieval)
    }
    
    func completeDeletion(with result: Result<Void, Error>, at index: Int = 0) {
        if case let .failure(error) = result {
            deletionCompletions[index](error)
        } else {
            deletionCompletions[index](nil)
        }
    }
    
    func completionInsertion(with result: Result<Void, Error>, at index: Int = 0) {
        if case let .failure(error) = result {
            insertionCompletions[index](error)
        } else {
            insertionCompletions[index](nil)
        }
    }
    
    func completionRetrieval(with result: Result<Void, Error>, at index: Int = 0) {
        if case let .failure(error) = result {
            retrievalCompletions[index](error)
        } else {
            retrievalCompletions[index](nil)
        }
    }
}
