//
//  MainThreadDecorator.swift
//  EssentialFeed
//
//  Created by Anthony on 3/11/24.
//
import Foundation
import EssentialFeed
import Combine

extension Publisher where Output == [FeedImage] {
    func dispatchToMainThread() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.ImmediateWhenOnMainQueue).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var ImmediateWhenOnMainQueue: ImmediateWhenOnMainQueueScheduler {
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



class MainThreadDecorator<T> {
    let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(_ block: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: block)
            return
        }
       
        block()
    }
}

extension MainThreadDecorator: FeedLoaderProtocol where T == FeedLoaderProtocol {
    func load(completion: @escaping (FeedLoaderProtocol.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainThreadDecorator: FeedImageDataLoaderProtocol where T == FeedImageDataLoaderProtocol {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoaderProtocol.Result) -> Void) -> any ImageLoadingDataTaskProtocol {
        decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch {completion(result)}
        }
    }
}
