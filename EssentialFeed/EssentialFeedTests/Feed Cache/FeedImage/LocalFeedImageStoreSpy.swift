//
//  LocalFeedImageStoreSpy.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//
import Foundation
import EssentialFeed

class LocalFeedImageStoreSpy: LocalFeedImageStoreProtocol {

    private(set) var receivedMessages: [Message] = []
    private var retrievalCompletions = [(RetrievalResult) -> Void]()
    private var insertionCompletions = [(InsertionResult) -> Void]()
    
    enum Message: Equatable {
        case retrieveData(for: URL)
        case insert(_: Data, for: URL)
    }
    
    typealias Result = Swift.Result<Data?, Error>
    
    // MARK: - Retrieve
    func retrieveData(for url: URL, completion: @escaping (Result) -> Void) {
        receivedMessages.append(.retrieveData(for: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with result: Result, at index: Int = 0) {
        retrievalCompletions[index](result)
    }
    
    // MARK: - Insert
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeInsert(with result: InsertionResult, at index: Int = 0) {
        insertionCompletions[index](result)
    }
}
