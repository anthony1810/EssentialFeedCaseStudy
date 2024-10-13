//
//  FeedStoreSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 13/10/24.
//

import EssentialFeed
import Foundation
public class FeedStoreSpy: FeedStore {
    
    enum ReceiveMessage: Equatable {
        case deletedCache
        case insertedCache([LocalFeedImage], Date)
        case retrieved
    }
    
    private(set) var deletionCompletions = [DeletionCacheCompletion]()
    private(set) var insertionCompletions = [InsertionCacheCompletion]()
    
    private(set) var receivedMessages = [ReceiveMessage]()
    
    public func deleteCache(completion: @escaping DeletionCacheCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deletedCache)
    }
    
    public func insertCache(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping (Error?) -> Void) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insertedCache(items, timestamp))
    }
    
    public func retrieve() {
        receivedMessages.append(.retrieved)
    }
    
    func completeDeletion(error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
}
