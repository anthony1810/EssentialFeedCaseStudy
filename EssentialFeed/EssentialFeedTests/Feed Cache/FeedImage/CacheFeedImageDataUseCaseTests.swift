//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeed
//
//  Created by Anthony on 17/11/24.
//

import Foundation
import EssentialFeed
import XCTest

class CacheFeedImageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreating() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_saveImageData_requestsURLInsertionIntoStore() {
        let (store, sut) = makeSUT()
        let imageData = makeAnyData()
        let imageURL = makeAnyUrl()
        
        sut.save(imageData, for: imageURL){ _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(imageData, for: imageURL)])
    }
    
    func test_saveImageData_failsOnStoreInsertionError() {
        let (store, sut) = makeSUT()
        let imageData = makeAnyData()
        let imageURL = makeAnyUrl()
        
        var expectedResult: LocalFeedImageDataLoader.SaveResult?
        let exp = expectation(description: "Waiting for saving new image")
        sut.save(imageData, for: imageURL, completion: { expectedResult = $0; exp.fulfill() })
        store.completeInsert(with: .failure(LocalFeedImageDataLoader.SaveError.failed))
        wait(for: [exp], timeout: 1.0)
        
        switch expectedResult {
        case .failure(let error):
            XCTAssertEqual(error as LocalFeedImageDataLoader.SaveError, .failed)
        default:
            XCTFail("Unexpected result: \(String(describing: expectedResult))")
        }
    }
}

extension CacheFeedImageDataUseCaseTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: LocalFeedImageStoreSpy, sut: LocalFeedImageDataLoader) {
        
        let store = LocalFeedImageStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }

}
