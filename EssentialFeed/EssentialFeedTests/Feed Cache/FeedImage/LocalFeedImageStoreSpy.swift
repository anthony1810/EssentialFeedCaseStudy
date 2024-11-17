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
    private var completions = [(Result) -> Void]()
    
    enum Message: Equatable {
        case retrieveData(for: URL)
        case insert(_: Data, for: URL)
    }
    
    typealias Result = Swift.Result<Data?, Error>
    
    // MARK: - Retrieve
    func retrieveData(for url: URL, completion: @escaping (Result) -> Void) {
        receivedMessages.append(.retrieveData(for: url))
        completions.append(completion)
    }
    
    func complete(with result: Result, at index: Int = 0) {
        completions[index](result)
    }
    
    // MARK: - Insert
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data, for: url))
    }
}
