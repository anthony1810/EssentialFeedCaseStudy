//
//  Untitled.swift
//  EssentialFeed
//
//  Created by Anthony on 19/10/24.
//

import Foundation

final class FeedCachePolicy {
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init() {}
    
    static func validateTimestampt(_ timestamp: Date, against date: Date) -> Bool {
        let maxCacheAge = calendar.date(byAdding: .day, value: -maxCacheDays, to: date)!

        return timestamp <= maxCacheAge
    }
    
    static var maxCacheDays: Int {
        7
    }
}
