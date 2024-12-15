//
//  Publisher+FeedImageDataCacheProtocol.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//

import Foundation
import EssentialFeed
import Combine

extension Publisher where Output == Data {
    func cache(to cacher: FeedImageDataCacheProtocol, with url: URL) -> AnyPublisher<Output, Failure> {
        self.handleEvents(receiveOutput: { data in
            cacher.saveCacheIgnoreCompletion(data: data, url: url)
        }).eraseToAnyPublisher()
    }
}
