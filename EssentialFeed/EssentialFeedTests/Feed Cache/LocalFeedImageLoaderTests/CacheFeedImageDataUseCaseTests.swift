//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 13/4/25.
//

import Foundation
import XCTest
import EssentialFeed

final class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_saveImageDataForURL_requestsImageDataInsertionForURL() throws {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anydata()
        
        try sut.save(data, for: url)
        
        XCTAssertEqual(store.receivedMessages, [.insert(dataFor: url)])
    }
    
    func test_saveImageDataForURL_deliversErrorOnStoreInsertionError() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        expect(sut, toFinishWith: saveFailed(), from: url) {
            store.completeInsertion(with: .failure(anyNSError()))
        }
    }
    
    func test_saveImageDataFromURL_succeedsOnSuccessfullStoreInsertion() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        expect(sut, toFinishWith: .success(()), from: url) {
            store.completeInsertion(with: .success(()))
        }
    }
    
    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func saveFailed() -> Swift.Result<Void, Error> {
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    private func expect(
        _ sut: LocalFeedImageDataLoader,
        toFinishWith expectedResult: Swift.Result<Void, Error>,
        from url: URL,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        action()
        
        let actualResult = Result { try sut.save(anydata(), for: url) }
        
        switch (actualResult, expectedResult) {
        case (.success, .success):
            break
        case let (.failure(actualError as LocalFeedImageDataLoader.SaveError), .failure(expectedError as LocalFeedImageDataLoader.SaveError)):
            XCTAssertEqual(actualError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected \(expectedResult), got \(actualResult) instead", file: file, line: line)
        }
    }
}
