//
//  LocalFeedImageStoreProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//

import Foundation

public protocol LocalFeedImageStoreProtocol {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Data?, Error>
    
    func retrieveData(for url: URL, completion: @escaping (Result) -> Void)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

