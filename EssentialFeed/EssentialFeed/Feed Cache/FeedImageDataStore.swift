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
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
