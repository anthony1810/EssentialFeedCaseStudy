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
    var completions: [(FeedImageDataStore.RetrievalResult) -> Void]  = []
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        completions.append(completion)
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(dataFor: url))
    }
    
    func completeRetrieval(with result: FeedImageDataStore.RetrievalResult, at index: Int = 0) {
        completions[index](result)
    }
}
