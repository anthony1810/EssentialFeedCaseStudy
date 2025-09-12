//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Anthony on 13/4/25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(dataForURL url: URL) throws -> Data?
    func insert(_ data: Data, for url: URL) throws
    
    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void)
    
    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

public extension FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data? {
        var result: Swift.Result<Data?, Error>!
        let group = DispatchGroup()
        group.enter()
        
        self.retrieve(dataForURL: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        
        return try result.get()
    }
    
    func insert(_ data: Data, for url: URL) throws {
        var result: Swift.Result<Void, Error>!
        let group = DispatchGroup()
        group.enter()
        
        self.insert(data, for: url) {
            result = $0
            group.leave()
        }
        
        group.wait()
        
        return try result.get()
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {}
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
}
