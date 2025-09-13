//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Anthony on 27/7/25.
//
import Foundation
import UIKit
import Combine
import os

import EssentialFeed

public extension Publisher {
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime()
        return handleEvents(
            receiveSubscription: { _ in
                logger.trace("Started loading \(url)")
                startTime = CACurrentMediaTime()
            },
            receiveOutput: { _ in
                let elapsedTime = CACurrentMediaTime() - startTime
                logger.trace("Finished loading \(url) in \(elapsedTime) seconds")
            }
        )
        .eraseToAnyPublisher()
    }
    
    func logCacheMisses(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(
            receiveCompletion: { completion in
                if case .failure = completion {
                    logger.trace("Missed Cache for \(url)")
                }
            }
        )
        .eraseToAnyPublisher()
    }

    func logLoadMorePage(logger: Logger, function: StaticString = #function) -> AnyPublisher<Output, Failure> where Output == ([FeedImage], FeedImage?) {
        handleEvents(receiveOutput: { (oldItems, last) in
            logger.trace("\(function) loaded \(oldItems.count) items, last \(last?.id.uuidString ?? "nil")")
        })
        .eraseToAnyPublisher()
    }
}

public extension Paginated {
    init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)? = nil) {
        self.init(items: items, loadMore: loadMorePublisher.map { publisher in
            { loadMoreCompletion in
                publisher().subscribe(Subscribers.Sink(receiveCompletion: { result in
                    if case let .failure(error) = result {
                        loadMoreCompletion(.failure(error))
                    }
                }, receiveValue: { value in
                    loadMoreCompletion(.success(value))
                }))
            }
        })
    }
    
    var loadMorePublisher: (() -> AnyPublisher<Self, Swift.Error>)? {
        guard let loadMore else { return nil }
        
        return Deferred {
            Future(loadMore)
        }.eraseToAnyPublisher
    }
}
public extension LocalFeedLoader {
    typealias Publisher = AnyPublisher<[FeedImage], Error>
    
    func loadPublisher() -> Publisher {
        Deferred {
            Future(self.load)
        }.eraseToAnyPublisher()
    }
}

public extension FeedImageDataLoader {
    typealias Publisher = AnyPublisher<Data, Swift.Error>
    
    func loadPublisher(from url: URL) -> Publisher {
        return Deferred {
            Future { promise in
                promise(Result{ try self.loadImageData(from: url) })
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == [FeedImage] {
        handleEvents(receiveOutput: {
            feed in cache.saveIgnoringCompletion(feed: feed) }
        )
        .eraseToAnyPublisher()
    }
    
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> where Output == Paginated<FeedImage> {
        handleEvents(receiveOutput: {
            page in cache.saveIgnoringCompletion(feed: page.items) }
        )
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func caching(to cacher: FeedImageCache, using url: URL) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: {
            cacher.saveIgnoringResult(data: $0, for: url)
        })
        .eraseToAnyPublisher()
    }
}

extension FeedCache {
    func saveIgnoringCompletion(feed: [FeedImage]) {
        self.save(feed) { _ in }
    }
}

extension FeedImageCache {
    func saveIgnoringResult(data: Data, for url: URL) {
        try? save(data, for: url)
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher {
    func dispatchOnMainQueueIfNeeded() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.immediateWhenOnMainQueue).eraseToAnyPublisher()
    }
    
    func subscribe(onSome scheduler: some Scheduler) -> AnyPublisher<Output, Failure> {
        subscribe(on: scheduler).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueue: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler()
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions

        var now: Self.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: Self.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }

        func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard Thread.isMainThread else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }

        /// Performs the action at some time after the specified date.
        func schedule(after date: Self.SchedulerTimeType, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }

        /// Performs the action at some time after the specified date, at the specified frequency, optionally taking into account tolerance if possible.
        func schedule(after date: Self.SchedulerTimeType, interval: Self.SchedulerTimeType.Stride, tolerance: Self.SchedulerTimeType.Stride, options: Self.SchedulerOptions?, _ action: @escaping () -> Void) -> any Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}

public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(for url: URL) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.get(from: url, completion: completion)
            }
        }
        .handleEvents(receiveCancel: {
            task?.cancel()
        })
        .eraseToAnyPublisher()
    }
}
