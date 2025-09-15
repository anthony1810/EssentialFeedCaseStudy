//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Anthony on 13/4/25.
//

import Foundation

public protocol FeedImageDataStore {
    func retrieve(dataForURL url: URL) throws -> Data?
    func insert(_ data: Data, for url: URL) throws
}
