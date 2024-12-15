//
//  Publisher+ImmediateWhenOnMainQueue.swift
//  EssentialApp
//
//  Created by Anthony on 1/12/24.
//

import Combine
import EssentialFeed
import Foundation

extension Publisher where Output == [FeedImage] {
    func dispatchToMainThread() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.ImmediateWhenOnMainQueue).eraseToAnyPublisher()
    }
}

extension Publisher where Output == Data {
    func dispatchToMainThread() -> AnyPublisher<Output, Failure> {
        receive(on: DispatchQueue.ImmediateWhenOnMainQueue).eraseToAnyPublisher()
    }
}

extension DispatchQueue {
    static var ImmediateWhenOnMainQueue: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {

        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType

        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }

        var now: Self.SchedulerTimeType {
            DispatchQueue.main.now
        }

        var minimumTolerance: Self.SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        private var isMainQueue: Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }

        func schedule(options: Self.SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue else {
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
