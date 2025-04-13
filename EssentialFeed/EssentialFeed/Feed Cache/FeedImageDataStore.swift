//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Anthony on 13/4/25.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void)
}
