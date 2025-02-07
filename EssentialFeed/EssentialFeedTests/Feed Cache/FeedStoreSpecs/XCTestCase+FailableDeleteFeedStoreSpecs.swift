//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Anthony on 6/2/25.
//
import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    func assertThatDeleteDeliversErrorWhenDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let receivedError = deleteCache(from: sut)
        XCTAssertNotNil(receivedError, "Expect error is delivers when encounter error", file: file, line: line)
    }
}
