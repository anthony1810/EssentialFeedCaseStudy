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
    var retrivalCompletions: FeedImageDataStore.RetrievalResult?
    var insertionCompletions: FeedImageDataStore.InsertionResult?
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataFor: url))
        return try retrivalCompletions?.get()
    }
    
    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(dataFor: url))
        try insertionCompletions?.get()
    }
    
    func completeRetrieval(with result: Swift.Result<Data?, Error>) {
        retrivalCompletions = result
    }
    
    func completeInsertion(with result: Swift.Result<Void, Error>) {
        insertionCompletions = result
    }
}
