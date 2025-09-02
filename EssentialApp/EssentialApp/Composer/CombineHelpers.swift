//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Anthony on 27/7/25.
//
import Foundation
import Combine
import EssentialFeed

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
        var task: FeedImageDataLoaderTask?
        return Deferred {
            Future { promise in
                task = self.loadImageData(from: url, completion: promise)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

extension Publisher where Output == [FeedImage] {
    func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
        handleEvents(receiveOutput: {
            feed in cache.saveIgnoringCompletion(feed: feed) }
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
        save(data, for: url) { _ in }
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
