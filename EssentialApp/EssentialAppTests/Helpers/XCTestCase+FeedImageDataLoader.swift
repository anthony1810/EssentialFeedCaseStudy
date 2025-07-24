//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//
import XCTest
import Foundation

import EssentialFeed


protocol FeedImageDataLoaderTestable: XCTestCase {}
extension FeedImageDataLoaderTestable {
    func expect(
        _ sut: FeedImageDataLoader,
        toFinishWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let expectation = self.expectation(description: "wait for image data to load")
        _ = sut.loadImageData(from: anyURL()) { actualResult in
            switch (actualResult, expectedResult) {
            case (.success(let actualData), .success(let expectedData)):
                XCTAssertEqual(actualData, expectedData, file: file, line: line)
            case (.failure(let actualError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(actualError, expectedError, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult), got \(actualResult)", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
