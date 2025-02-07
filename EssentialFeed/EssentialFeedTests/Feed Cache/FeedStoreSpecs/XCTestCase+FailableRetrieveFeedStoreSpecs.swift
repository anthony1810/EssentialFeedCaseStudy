//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeed
//
//  Created by Anthony on 6/2/25.
//
import Foundation
import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toReceive: .failure(anyNSError()))
    }
    
    func assertThatRetrieveDeliversFailureHasNoSideEffectsOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toReceiveTwice: .failure(anyNSError()))
    }
}
