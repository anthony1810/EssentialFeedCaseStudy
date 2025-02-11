//
//  XCTestCase+FailableInsertionFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Anthony on 6/2/25.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let receiveError = insert(items: [uniqueFeed().local], timestamp: Date(), to: sut)
        
        XCTAssertNotNil(receiveError, "Expected error when insertion encounter error")
    }
}
