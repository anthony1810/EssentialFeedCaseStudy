//
//  FeedCacheProtocol.swift
//  EssentialFeed
//
//  Created by Anthony on 23/11/24.
//
import Foundation

public protocol FeedCacheProtocol {
    typealias SaveResult = Error?
    
    func save(_ items: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
