//
//  FeedImageCache.swift
//  EssentialFeed
//
//  Created by Anthony on 20/7/25.
//
import Foundation

public protocol FeedImageCache {
    func save(_ data: Data, for url: URL) throws
}
