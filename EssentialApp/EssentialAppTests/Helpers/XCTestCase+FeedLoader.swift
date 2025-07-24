//
//  XCTestCase+FeedLoader.swift
//  EssentialApp
//
//  Created by Anthony on 20/7/25.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(
        _ sut: FeedLoader,
    toFinishWith expectedResult: FeedLoader.Result,
    file: StaticString = #file,
    line: UInt = #line
    ) {
        let expectation = XCTestExpectation(description: "Wait for load")
        sut.load { actualResult in
            switch (actualResult, expectedResult) {
                case (.success(let actual), .success(let expected)):
                    XCTAssertEqual(actual, expected, file: file, line: line)
            case  (.failure(let actual as NSError), .failure(let expected as NSError)):
                XCTAssertEqual(actual, expected, file: file, line: line)
                default:
                    XCTFail("Expected \(expectedResult), got \(actualResult) instead", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
