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
    
    func test_saveImagedata_succeedsOnStoreInsertionSuccess() {
        let (store, sut) = makeSUT()
        let imageData = makeAnyData()
        
        expect(sut: sut, toFinishSaveImageWith: .success(imageData)) {
            store.completeInsert(with: .success(imageData))
        }
    }
    
    func test_saveImageData_doesNotDeliverResultAfterInstanceDeallocated() {
        let store = LocalFeedImageStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        
        var capturedResult: LocalFeedImageDataLoader.SaveResult?
        sut?.save(makeAnyData(), for: makeAnyUrl(), completion: { capturedResult = $0 })
        
        sut = nil
        store.completeInsert(with: .success(makeAnyData()))
        
        XCTAssertTrue(capturedResult == nil)
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
        .failure(LocalFeedImageDataLoader.SaveError.failed)
    }
    
    func expect(
        sut: LocalFeedImageDataLoader,
        toFinishSaveImageWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

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
        case let (.failure(expectedError as NSError), .failure(capturedError as NSError)):
            XCTAssertEqual(expectedError, capturedError, file: file, line: line)
        case let (.success(expectedData), .success(capturedData)):
            XCTAssertEqual(expectedData, capturedData, file: file, line: line)
        default:
            XCTFail("Unexpected result: \(String(describing: capturedResult))", file: file, line: line)
        }
    }
}
