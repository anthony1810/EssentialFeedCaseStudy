//
//  CoreDataFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Anthony on 7/2/25.
//

import EssentialFeed
import Foundation
import XCTest

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyCacheOnEmptyCache() throws {
        try makeSUT { [weak self] sut in
            self?.assertThatRetrieveDeliversEmptyCacheOnEmptyCache(on: sut)
        }
    }

    func test_retrieveTwice_deliversSameEmptyCacheOnEmptyCache() throws {
       try makeSUT { [weak self] sut in
            self?.assertThatRetrieveHasNoSideEffectOnDeliversEmptyCache(on: sut)
        }
    }

    func test_retrieve_deliversNonEmptyCacheOnNonEmptyCache() throws {
        try makeSUT { [weak self] sut in
            self?.assertThatRetrieveDeliversFoundCacheOnNonEmptyCache(on: sut)
        }
    }

    func test_retrieve_deliversFoundCacheHasNoSideEffects() throws {
        try makeSUT() { [weak self] sut in
            self?.assertThatRetrieveHasNoSideEffectOnDeliversFoundCache(on: sut)
        }
    }

    func test_insert_overridesExistingCacheOnNonEmptyCache() throws {
        try makeSUT { [weak self] sut in
            self?.assertThatInsertOverridesExistingCacheOnNonEmptyCache(on: sut)
        }
    }

    func test_insert_overridesExistingCacheOnNonEmptyCacheHasNoSideEffect()
        throws
    {
        try makeSUT() { [weak self] sut in
            self?.assertThatInsertHasNoSideEffectOverridesExistingCacheOnNonEmptyCache(
                on: sut
            )
        }
    }

    func test_delete_deliversSuccessOnEmptyCache() throws {
        try makeSUT { [weak self] sut in
            self?.assertThatDeleteDeliversSuccessOnNonEmptyCache(on: sut)
        }
    }

    func test_delete_deliversSuccessOnNonEmptyCache() throws {
        try makeSUT { [weak self] sut in
            self?.assertThatDeleteDeliversSuccessOnNonEmptyCache(on: sut)
        }
    }

    // MARK: - Helpers
    @discardableResult
    func makeSUT(
        action: @escaping (CoreDataFeedStore) -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> CoreDataFeedStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try CoreDataFeedStore(storeURL: storeURL)
        trackMemoryLeaks(sut, file: file, line: line)

        let expect = expectation(description: "wait for load")
        sut.perform(action: {
            action(sut)
            expect.fulfill()
        })
        wait(for: [expect], timeout: 0.1)

        return sut
    }
}
