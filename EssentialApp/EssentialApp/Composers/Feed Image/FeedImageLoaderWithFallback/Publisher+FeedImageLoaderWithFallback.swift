//
//  Publisher+FeedImageLoaderWithFallback.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//
import Foundation
import EssentialFeed
import Combine

extension Publisher where Output == Data {
    func fallback(to fallback: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallback() }.eraseToAnyPublisher()
    }
}
