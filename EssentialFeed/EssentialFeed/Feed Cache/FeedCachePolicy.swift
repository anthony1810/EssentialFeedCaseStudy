//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Anthony on 3/2/25.
//
import Foundation

public struct FeedCachePolicy {
    static var currentCalendar: Calendar = Calendar(identifier: .gregorian)
    public static var maxCacheDays: Int { 7 }
    
    public static func isCacheValidated(with timestamp: Date, against currentTimestamp: Date) -> Bool {
        guard let maxCacheAge = currentCalendar.date(byAdding: .day, value: maxCacheDays, to: timestamp)
        else { return false }
        
        return currentTimestamp < maxCacheAge
    }
}
