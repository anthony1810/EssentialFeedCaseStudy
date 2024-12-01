//
//  Publisher+FeedCacheProtocol.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//

import Combine
import EssentialFeed

// combine remote feed loader with caching
public extension Publisher where Output == [FeedImage] {
    func cache(to cacher: FeedCacheProtocol) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveOutput: cacher.saveCacheIgnoreCompletion).eraseToAnyPublisher()
    }
}
