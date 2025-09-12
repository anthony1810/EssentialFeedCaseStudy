//
//  FeedImagedataStoreSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 13/4/25.
//
import Foundation
import EssentialFeed

final class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(dataFor: URL)
    }
    
    var receivedMessages: [Message] = []
    var retrivalCompletions: [(FeedImageDataStore.RetrievalResult) -> Void]  = []
    var insertionCompletions: FeedImageDataStore.InsertionResult?
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrivalCompletions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(dataFor: url))
        try insertionCompletions?.get()
    }
    
    func completeRetrieval(with result: FeedImageDataStore.RetrievalResult, at index: Int = 0) {
        retrivalCompletions[index](result)
    }
    
    func completeInsertion(with result: LocalFeedImageDataLoader.SaveResult) {
        insertionCompletions = result
    }
}
