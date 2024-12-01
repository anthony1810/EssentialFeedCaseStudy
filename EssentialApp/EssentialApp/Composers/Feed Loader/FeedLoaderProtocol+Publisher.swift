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
        Deferred {
            Future { promise in
                self.load { result in
                    switch result {
                    case .success(let feeds):
                        return promise(.success(feeds))
                    case .failure(let error):
                        return promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

