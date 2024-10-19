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
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: -maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
    
    static var maxCacheAgeInDays: Int {
        7
    }
}
