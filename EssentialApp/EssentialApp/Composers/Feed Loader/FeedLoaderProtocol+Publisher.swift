//
//  FeedLoaderProtocol+Publisher.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//

import Combine
import EssentialFeed

public extension FeedLoaderProtocol {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
        Deferred { Future(self.load) }.eraseToAnyPublisher()
    }
}

