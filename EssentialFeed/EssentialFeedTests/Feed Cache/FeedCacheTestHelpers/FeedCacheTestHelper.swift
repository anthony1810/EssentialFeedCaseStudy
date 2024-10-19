//
//  FeedCacheTestHelper.swift
//  EssentialFeed
//
//  Created by Anthony on 19/10/24.
//

import XCTest
import Foundation
import EssentialFeed

class FeedCacheTests: XCTestCase {
    func makeSUT(timestamp: @escaping (() -> Date) = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, feedLoader: LocalFeedLoader) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (store: store, feedLoader: sut)
    }
    
    
    func uniqueItem() -> (domainModel: FeedImage, localModel: LocalFeedImage) {
        let domain = FeedImage(id: UUID(), description: nil, location: nil, imageURL: makeAnyUrl())
        let local = LocalFeedImage(id: domain.id, description: domain.description, location: domain.location, url: domain.imageURL)
        
        return (domain, local)
    }
}

extension Date {
    var cacheExpireDate: Date {
        return Calendar.current.date(byAdding: .day, value: daysToExpire, to: Date())!
    }
    
    var daysToExpire: Int {
        7
    }
    
    func addingSeconds(_ seconds: Int) -> Date {
        return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
    }
}
