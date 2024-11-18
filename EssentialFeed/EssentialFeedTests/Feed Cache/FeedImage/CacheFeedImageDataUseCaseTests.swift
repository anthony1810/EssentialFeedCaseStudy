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
      
        expect(sut: sut, toFinishSaveImageWith: saveFailed()) {
            store.completeInsert(with: .failure(LocalFeedImageDataLoader.SaveError.failed))
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
    
    func saveFailed() -> LocalFeedImageDataLoader.SaveResult {
        .failure(.failed)
    }
    
    func expect(sut: LocalFeedImageDataLoader, toFinishSaveImageWith expectedResult: LocalFeedImageDataLoader.SaveResult, when action: () -> Void) {

        let imageData = makeAnyData()
        let imageURL = makeAnyUrl()
        
        var capturedResult: LocalFeedImageDataLoader.SaveResult?
        let exp = expectation(description: "Waiting for saving new image")
        sut.save(
            imageData,
            for: imageURL,
            completion: {
                capturedResult = $0
                exp.fulfill() })
       
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        switch (expectedResult, capturedResult) {
        case let (.failure(expectedError), .failure(capturedError)):
            XCTAssertEqual(expectedError, capturedError)
        case let (.success(expectedData), .success(capturedData)):
            XCTAssertEqual(expectedData, capturedData)
        default:
            XCTFail("Unexpected result: \(String(describing: expectedResult))")
        }
    }
}
